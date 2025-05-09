#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/rtc.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/bcd.h>

#define HT1382_SECONDS		0x00	/* Seconds register address */
#define HT1382_STOP		0x80	/* Oscillator Stop flag */
#define HT1382_HOUR_1224	0x80	/* 12/24 flag */
#define HT1382_HOUR_AMPM	0x20	/* AM/PM flag */

#define HT1382_ST1		0x07	/* Status register address */
#define HT1382_WP		0x80	/* Write Protect flag */

struct ht1382_regs {
	uint8_t		second;
	uint8_t		minute;
	uint8_t		hour;
	uint8_t		date;
	uint8_t		month;
	uint8_t		day;
	uint8_t		year;
};

static struct i2c_driver ht1382_driver;

static int ht1382_read(struct device *dev, void *data, uint8_t off, uint8_t len)
{
	struct i2c_client *client = to_i2c_client(dev);
	struct i2c_msg msgs[] = {
		{
			.addr = client->addr,
			.flags = 0,
			.len = 1,
			.buf = &off,
		}, {
			.addr = client->addr,
			.flags = I2C_M_RD,
			.len = len,
			.buf = data,
		}
	};

	if (i2c_transfer(client->adapter, msgs, 2) == 2)
		return 0;

	return -EIO;
}

static int ht1382_write(struct device *dev, void *data, uint8_t off, uint8_t len)
{
	struct i2c_client *client = to_i2c_client(dev);
	static uint8_t buffer[64 * 1024];//max length for i2c_master_send

	if((len + 1) >= (64 * 1024)){
		return -EIO;
	}

	buffer[0] = off;
	memcpy(&buffer[1], data, len);

	if (i2c_master_send(client, buffer, len + 1) == (len + 1)){
		return 0;
	}

	return -EIO;
}

static int ht1382_rtc_read_time(struct device *dev, struct rtc_time *tm)
{
	struct ht1382_regs regs;
	int error;

	error = ht1382_read(dev, &regs, 0, sizeof(regs));
	if (error)
		return error;

	dev_dbg(dev,
		"%s: raw data is sec=%02x, min=%02x, hour=%02x, "
		"date=%02x, day=%02x, mon=%02x, "
		"year=%02x\n",
		__func__,
		regs.second,regs.minute,regs.hour,
		regs.date,regs.day,regs.month,regs.year);

	tm->tm_sec = bcd2bin(regs.second & 0x7f);
	tm->tm_min = bcd2bin(regs.minute & 0x7f);
        if (regs.hour & HT1382_HOUR_1224) {
                tm->tm_hour = bcd2bin(regs.hour & 0x1f);
                if (regs.hour & HT1382_HOUR_AMPM) tm->tm_hour += 12;
        } else {
                tm->tm_hour = bcd2bin(regs.hour & 0x3f);
	}
	tm->tm_mday = bcd2bin(regs.date);
	tm->tm_wday = bcd2bin(regs.day) - 1;
	tm->tm_mon = bcd2bin(regs.month) - 1;
	tm->tm_year = bcd2bin(regs.year) + 100;
	if (rtc_valid_tm(tm)) {
		dev_err(dev, "retrieved date/time is not valid.\n");		
		return -EINVAL;
	}
	return 0;
}

static int ht1382_rtc_set_time(struct device *dev, struct rtc_time *tm)
{
	struct ht1382_regs regs;
	uint8_t reg;
	int error;

	/* WP off */
	reg = 0;
	error = ht1382_write(dev, &reg, HT1382_ST1, 1);
	if (error)
		return error;

	regs.second = bin2bcd(tm->tm_sec);
	regs.minute = bin2bcd(tm->tm_min);
	regs.hour = bin2bcd(tm->tm_hour) | HT1382_HOUR_1224;
	regs.day = bin2bcd(tm->tm_wday + 1);
	regs.date = bin2bcd(tm->tm_mday);
	regs.month = bin2bcd(tm->tm_mon + 1);
	regs.year = bin2bcd(tm->tm_year % 100);

	error = ht1382_write(dev, &regs, 0, sizeof(regs));
	if (error)
		return error;

	/* WP on */
	reg = 0x80;
	return ht1382_write(dev, &reg, HT1382_ST1, 1);
}

static const struct rtc_class_ops ht1382_rtc_ops = {
	.read_time	= ht1382_rtc_read_time,
	.set_time	= ht1382_rtc_set_time,
};

static int ht1382_probe(struct i2c_client *client)
{
	struct device *dev = &client->dev;
	struct rtc_device *rtc;
	uint8_t reg;
	int error;

	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C))
		return -ENODEV;

	error = ht1382_read(dev, &reg, HT1382_SECONDS, 1);
	if (!error && (reg & HT1382_STOP)) {
		/* WP off */
		reg = 0;
		ht1382_write(dev, &reg, HT1382_ST1, 1);

		dev_warn(dev, "Oscillator was halted. Restarting...\n");
		reg &= ~HT1382_STOP;
		error = ht1382_write(dev, &reg, HT1382_SECONDS, 1);

		/* WP on */
		reg = 0x80;
		ht1382_write(dev, &reg, HT1382_ST1, 1);
	}
	if (error)
		return error;

	rtc = devm_rtc_device_register(&client->dev, ht1382_driver.driver.name,
						&ht1382_rtc_ops, THIS_MODULE);
	if (IS_ERR(rtc))
		return PTR_ERR(rtc);

	i2c_set_clientdata(client, rtc);

	return 0;
}

static const struct i2c_device_id ht1382_id[] = {
	{ "ht1382", 0 },
	{ }
};
MODULE_DEVICE_TABLE(i2c, ht1382_id);

static const struct of_device_id ht1382_of_match[] = {
        { .compatible = "htk,ht1382" },
        {}
};
MODULE_DEVICE_TABLE(of, ht1382_of_match);

static struct i2c_driver ht1382_driver = {
	.driver = {
		.name	= "ht1382",
		.owner	= THIS_MODULE,
		.of_match_table = ht1382_of_match,  
	},
	.probe		= ht1382_probe,
	.id_table	= ht1382_id,
};

module_i2c_driver(ht1382_driver);

MODULE_DESCRIPTION("Holtek 1382 I2C RTC driver");
MODULE_LICENSE("GPL");
