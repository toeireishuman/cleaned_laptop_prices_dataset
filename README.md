# cleaned_laptop_prices_dataset
This project demonstrates my proficiency in SQL for data cleaning.

This project uses the [uncleaned laptop price dataset](https://www.kaggle.com/datasets/ehtishamsadiq/uncleaned-laptop-price-dataset/data), which inlcudes information about laptop models and specifications, such as the brand, cpu information, memory sizes, etc. Since this dataset is not clean, this project is intended to prepare the dataset for data analysis.

The summary of the data cleaning includes:
- normalizing the column names
- obtaining relevant information from existing columns such as:
    - extracting the CPU speed and brand from the "cpu" column into their own corresponding columns, "cpu_speed" and "cpu_brand", and
    - extracting the memory types and sizes from the "total_memory" column into their own respective columns: "ssd_memory", "hdd_memory", and "flash_memory"
- establishing the data types for all columns, 
- removing blanks, duplicates, and, in the case of "N/A" values (such as "No OS" in the "operating_system" column and "?" in various columns), replace with default NULL values, and
- rearranging the columns.
