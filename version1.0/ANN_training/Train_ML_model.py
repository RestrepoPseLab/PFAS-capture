# import the necessary packages
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import time

import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
os.environ["JAX_PLATFORMS"] = "cpu"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
os.environ["KERAS_BACKEND"] = "tensorflow"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "1"

import tensorflow as tf
from keras.layers import Dense, Input
from keras.models import Sequential
from keras.optimizers import Adam
from keras.callbacks import ModelCheckpoint, EarlyStopping

from pathlib import Path

start_time = time.perf_counter()

base = Path(__file__).resolve().parent
csv_path = base / "training_data" / "GAC_60k_CORRECTED_26-03-2026.csv"

# reading csv data
columns = [
    "capacity",
    "diameter",
    "column_height",
    "porosity",
    "ads_time",
    "C_o",
    "total_LCP",
    "emissions",
    "PFAS_eff",
    "PFAS_ads",
    ]

df1 = pd.read_csv(csv_path, usecols=columns)
df = df1.dropna(ignore_index=True)

epsilon = 1e-20
# cleaning data
df.loc[:, 'PFAS_eff'] = df['PFAS_eff'].clip(lower=0)
df = df[(df['total_LCP'] >= 0)].copy()
df['total_LCP'] = np.log(df['total_LCP'])
df['emissions'] = np.log(df['emissions'])
df['PFAS_eff'] = np.log(df['PFAS_eff'] + epsilon)

print(f"Data shape after cleaning: {df.shape}")

# separate the data into inputs and outputs
inputs = ["capacity", "diameter", "column_height", "porosity", "ads_time", "C_o"]
outputs = [
    "total_LCP",
    "emissions",
    "PFAS_eff"
]
dfin = df[inputs]
dfout = df[outputs]

# define a function to scale the data using min-max scaling
def min_max_scaler(data, data_min, data_max):
    return (data - data_min) /(data_max - data_min)

# define a function to reverse the scaling
def reverse_min_max_scaler(scaled_data, data_min, data_max):
    return scaled_data * (data_max - data_min) + data_min

# scale the data
x_data_min = dfin.min()
x_data_max = dfin.max()
y_data_min = dfout.min()
y_data_max = dfout.max()

x_data_scaled = min_max_scaler(dfin, x_data_min, x_data_max)
y_data_scaled = min_max_scaler(dfout, y_data_min, y_data_max)

extrema_indices = set()

# Find the index of the min and max values for every column in X
for col in x_data_scaled.columns:
    extrema_indices.add(x_data_scaled[col].idxmin())
    extrema_indices.add(x_data_scaled[col].idxmax())

# Find the index of the min and max values for your target(s)
for col in y_data_scaled.columns:
    extrema_indices.add(y_data_scaled[col].idxmin())
    extrema_indices.add(y_data_scaled[col].idxmax())

# Convert the unique indices to a list
extrema_list = list(extrema_indices)

# Extract these exact rows from both X and y simultaneously
x_extrema = x_data_scaled.loc[extrema_list]
y_extrema = y_data_scaled.loc[extrema_list]

# Drop these rows from the datasets
x_remaining = x_data_scaled.drop(index=extrema_list)
y_remaining = y_data_scaled.drop(index=extrema_list)

# split the data into training and testing sets
x_train_scaled, x_test_scaled, y_train_scaled, y_test_scaled = train_test_split(
    x_remaining, y_remaining, test_size=0.1, random_state=42
)

# Add the min and max rows back to the training data
x_train_scaled = pd.concat([x_train_scaled, x_extrema], ignore_index=True)
y_train_scaled = pd.concat([y_train_scaled, y_extrema], ignore_index=True)

# define a function to build the model
le = 5e-5
no_epochs = 100000
def build_model():
    # create our Keras Sequential model
    nn = Sequential(name="PFAS_model")
    nn.add(Input(shape=(len(inputs),)))
    nn.add(Dense(30, activation="sigmoid"))
    nn.add(Dense(30, activation="sigmoid"))
    nn.add(Dense(30, activation="sigmoid"))
    nn.add(Dense(units=len(outputs)))
    
    nn.compile(
        optimizer=Adam(learning_rate=le), 
        loss="mse", 
        metrics=["mae", tf.keras.metrics.R2Score(name="r2_score")]
    )
    return nn

# build the model
model  = build_model()
model.summary()

# CALLBACKS 
# 1. Save the best model along the way
checkpoint = ModelCheckpoint(
    filepath="GAC_best_model_mse_sigmoid(30,30,30)_100k.keras",
    monitor="val_loss",
    verbose=0,
    save_best_only=True,
    mode="min"
)

# 2. Stop early if no improvement for 5000 epochs, and restore best weights
early_stop = EarlyStopping(
    monitor='val_loss',
    patience=5000,
    restore_best_weights=True,
    verbose=1
)

# train the model (now with callbacks included)
history = model.fit(
    x_train_scaled, 
    y_train_scaled, 
    epochs=no_epochs, 
    validation_data=(x_test_scaled, y_test_scaled), 
    verbose=0,
    callbacks=[checkpoint, early_stop]
)

# plot the history and save it
history_data = {
    "epoch": list(range(1, len(history.history["loss"]) + 1)),
    "train_loss": history.history["loss"],
    "val_loss": history.history["val_loss"],
    "train_r2": history.history["r2_score"],
    "val_r2": history.history["val_r2_score"],
}

df_history = pd.DataFrame(history_data)

# Save to Excel
df_history.to_excel("training_history_GAC_mse_sigmoid(30,30,30)_100k.xlsx", index=False)
print("Saved: training_history_GAC_mse_sigmoid(30,30,30)_100k.xlsx")

# plot loss (train & validation)
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.plot(df_history["epoch"], df_history["train_loss"], label="Training Loss")
plt.plot(df_history["epoch"], df_history["val_loss"], label="Validation Loss")
plt.title("Loss vs Epochs")
plt.xlabel("Epoch")
plt.ylabel("MSE Loss")
plt.legend()

# plot R2 score (train & validation)
plt.subplot(1, 2, 2)
plt.plot(df_history["epoch"], df_history["train_r2"], label="Training R2 Score")
plt.plot(df_history["epoch"], df_history["val_r2"], label="Validation R2 Score")
plt.title("R2 Score vs Epochs")
plt.xlabel("Epoch")
plt.ylabel("R2 Score")
plt.legend()

plt.tight_layout()
plt.savefig("model_performance_GAC_mse_sigmoid(30,30,30)_100k.png")
# plt.show()

print("Saved: model_performance_GAC_mse_sigmoid(30,30,30)_100k.png")


# using the test data, predict the outputs using the model and plot a graph against the actual values
y_pred_scaled = model.predict(x_test_scaled)
y_pred_scaled = pd.DataFrame(y_pred_scaled, columns=outputs)

# calculate and print the R2 score for each output
from sklearn.metrics import r2_score
print("\n--- Final Test Performance (Using Best Weights) ---")
for col in outputs:
    r2 = r2_score(y_test_scaled[col], y_pred_scaled[col])
    print(f'R2 score for {col}: {r2:.4f}')

column_names = {
    "total_LCP": "Cost",
    "emissions": "Emissions",
    "PFAS_eff": "Effluent Concentration"
}
# plot the results
for col in outputs:
    plt.figure()
    plt.scatter(y_test_scaled[col], y_pred_scaled[col], alpha=0.5)
    plt.plot([y_test_scaled[col].min(), y_test_scaled[col].max()], [y_test_scaled[col].min(), y_test_scaled[col].max()], 'k--', lw=2)
    plt.xlabel('Actual')
    plt.ylabel('Predicted')
    plt.title(f'{column_names.get(col,col)}', fontweight='bold')
    plt.savefig(f'model_performance_GAC_{col}_mse_sigmoid(30,30,30)_100k.png')
    # plt.show()
    

# save the final model (which is now guaranteed to be the best model)
model.save("GAC_sig_mse(30,30,30)_100k.keras")
print("Training complete and best model saved")

end_time = time.perf_counter()
execution_time = end_time - start_time
print(f"The simulation runtime was {execution_time:.6f} seconds")