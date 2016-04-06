import numpy as np
import pandas as pd
import csv

def power_consumption(sequence_length, ratio=1.0, is_daily=False):
  path_to_dataset = 'data/household_power_consumption.csv'

  # Append lines to data array
  df = pd.read_csv(path_to_dataset, delimiter=';')
  df = df.replace('?', np.nan)
  df = df.dropna()
  df['Global_active_power'] = pd.to_numeric(df['Global_active_power'])
  df_gap = df[['Date', 'Global_active_power']]
  # daily
  if is_daily:
    df_gap = df_gap.groupby('Date').aggregate(sum)
  gap_data = df_gap.Global_active_power.values
  data = gap_data[:int(ratio * len(gap_data))]

  print("Data loaded from csv.")
  print("Formatting data...")

  result = []
  for index in range(len(data) - sequence_length):
    result.append(data[index: index + sequence_length])
  result = np.array(result)  # shape (2049230, 50)

  # Normalise data by mean
  result_mean = result.mean()
  result -= result_mean
  print("Shift : ", result_mean)
  print("Data  : ", result.shape)

  # Split data 90% for train, 10% for test
  row = round(0.9 * result.shape[0])
  train = result[:row, :] # result[row, column]
  np.random.shuffle(train)
  X_train = train[:, :-1] # train without the last value
  y_train = train[:, -1] # only the last value (labels)
  X_test = result[row:, :-1] # 10% of test
  y_test = result[row:, -1] # labels for test

  X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
  X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

  return [X_train, y_train, X_test, y_test]
