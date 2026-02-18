import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import pickle

# Create dummy training data
data = {
    "quantity": [10, 20, 30, 40, 50],
    "price": [100, 200, 150, 300, 250],
}

df = pd.DataFrame(data)

# Sales = quantity * price
df["sales"] = df["quantity"] * df["price"]

X = df[["quantity", "price"]]
y = df["sales"]

model = LinearRegression()
model.fit(X, y)

# Save model
pickle.dump(model, open("sales_model.pkl", "wb"))

print("Model trained and saved successfully!")
