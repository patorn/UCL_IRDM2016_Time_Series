import matplotlib.pyplot as plt
import numpy as np
import time
import sys

import data_utils as data_utils
import graph_utils as graph_utils
import metrics as metrics

import h5py # for model.save_weights
from keras.layers.core import Dense, Activation, Dropout
from keras.layers.recurrent import LSTM
from keras.models import Sequential
from keras.callbacks import EarlyStopping

def build_model():
  model = Sequential()
  in_out_neurons = 1
  hidden_neurons = 50

  model.add(LSTM(
    input_dim=in_out_neurons,
    output_dim=hidden_neurons,
    return_sequences=False))
  model.add(Dropout(0.2))

  model.add(Dense(
    input_dim=hidden_neurons,
    output_dim=in_out_neurons))
  model.add(Activation("linear"))

  start = time.time()
  model.compile(loss="mse", optimizer="rmsprop")
  print("Compilation Time : ", time.time() - start)
  return model

def run(path_to_dataset, epochs=1, sequence_length=50, ratio=0.5):
  global_start_time = time.time()

  print('Loading data...')
  X_train, y_train, X_test, y_test = data_utils.power_consumption(path_to_dataset, sequence_length, ratio)

  print('Compiling model...')

  model = build_model()

  print('Fitting data...')
  try:
    early_stopping = EarlyStopping()
    model.fit(X_train, y_train, batch_size=100, nb_epoch=epochs, validation_split=0.05, show_accuracy=True, callbacks=[early_stopping])
    predictions = model.predict(X_test)
    predictions = np.reshape(predictions, (predictions.size,))
  except KeyboardInterrupt:
    print('Training duration (s) : ', time.time() - global_start_time)
    return model, y_test, 0

  print('Training duration (s) : ', time.time() - global_start_time)
  return model, y_test, predictions

# How to run
# python lstm.py daily
def main():
  if sys.argv[1] == 'daily':
    print('Using daily data...')
    path_to_dataset = '../data/household_power_consumption_daily.csv'
    model, y_test, predictions = run(path_to_dataset, 10, 50, 1.0)
  elif sys.argv[1] == 'hourly':
    print('Using hourly data...')
    path_to_dataset = '../data/household_power_consumption_hourly.csv'
    model, y_test, predictions = run(path_to_dataset, 30, 50, 1.0)
  else:
    print('Using minute data...')
    path_to_dataset = '../data/household_power_consumption.csv'
    model, y_test, predictions = run(path_to_dataset)

  # save for later use
  model.save_weights('../output/lstm.h5', overwrite=True)
  # model.load_weights('../output/lstm.h5')

  graph_utils.plot('lstm', predictions, y_test)

  print('RMSE: %.4f'% metrics.rmse(predictions, y_test))
  print('MAPE: %.4f'% metrics.mape(predictions, y_test))

  # minute
  # RMSE: 0.2616
  # MAPE: 26.15

  # hourly
  # RMSE: 31.3330
  # MAPE: 204.5651

  # daily
  # RMSE: 519.3943
  # MAPE: 98.1580

if __name__ == '__main__':
  main()
