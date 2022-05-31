
cJSON *
i2cset ( uint8_t chip_addr, uint8_t reg, cJSON * data);
cJSON *
i2cDump (uint8_t chip_addr, uint8_t size);
cJSON *
i2cget (uint8_t chip_addr, uint8_t data_addr, uint8_t len);
cJSON *
i2cScan ();
uint8_t i2c_gpio_scl ;
uint8_t i2c_gpio_sda ;
