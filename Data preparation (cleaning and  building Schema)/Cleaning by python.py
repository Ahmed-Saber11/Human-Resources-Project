import pandas as pd  # to read data
import matplotlib.pyplot as plt
import seaborn as sns
# Read the CSV file
df = pd.read_csv(r"D:\DATA ANALYSIS\DEPI\Final project Depi\Dataset\500000 Records - Copy.csv")

########## Handling Nulls ##########

# Fill missing values

df['E Mail'] = df['E Mail'].fillna('Unknown')
df['Phone No. '] = df['Phone No. '].fillna(df['Phone No. '].mode()[0])
df['City'] = df['City'].fillna('Unknown')
df['Region'] = df['Region'].fillna('Unknown')

# Check if any nulls remain (optional print)

print(df.isnull().sum())

# Drop duplicates
df.drop_duplicates(inplace=True)

# Check if any duplicates remain (optional print)
print(df.duplicated().sum())

# Optional: Check info and statistics
print(df.info())
print(df.describe())


# Some statistical description
df.describe()



#check outliers 

# We check the outliers of every feature using boxplot
plt.figure(figsize=(15,7))
sns.boxplot(data=df)
plt.show()

#there is no outliers

# Save cleaned data
df.to_csv(r'D:\DATA ANALYSIS\DEPI\Final project\500000 Records.csv\500000 Records.csv', index=False)









