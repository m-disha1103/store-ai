import pandas as pd
from sklearn.linear_model import LinearRegression
import joblib

data = {
    "quantity": [5, 10, 15, 20, 25],
    "price": [100, 100, 100, 100, 100],
    "sales": [500, 1000, 1500, 2000, 2500]
}

df = pd.DataFrame(data)

X = df[["quantity", "price"]]
y = df["sales"]

model = LinearRegression()
model.fit(X, y)

joblib.dump(model, "sales_model.pkl")

print("Model trained and saved")
