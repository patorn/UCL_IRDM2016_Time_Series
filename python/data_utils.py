import numpy as np
import pandas as pd
import csv

np.random.seed(1234)

def power_consumption(path_to_dataset, sequence_length, ratio=1.0):
  # Append lines to data array
  df = pd.read_csv(path_to_dataset, delimiter=';')
  df = df.replace('?', np.nan)
  df = df.dropna()
  df['Global_active_power'] = pd.to_numeric(df['Global_active_power'])
  df_gap = df[['Date', 'Global_active_power']]

  # # uncomment for daily data
  # df_gap = df_gap.groupby('Date').aggregate(sum)

  # # uncomment for hourly data
  # df['Date_Time'] = df['Date'] + ' ' + df['Time']
  # df_gap = df[['Date_Time', 'Global_active_power']]
  # times = pd.DatetimeIndex(df_gap.Date_Time)
  # df_gap = df_gap.groupby([times.date, times.hour]).aggregate(sum)

  # # uncomment for monthly data
  # df_gap = df[['Date', 'Global_active_power']]
  # times = pd.DatetimeIndex(df.Date)
  # df_gap = df_gap.groupby(times.to_period("M")).aggregate(sum)

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
