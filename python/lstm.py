import matplotlib.pyplot as plt
import numpy as np
import time
from keras.layers.core import Dense, Activation, Dropout
from keras.layers.recurrent import LSTM
from keras.models import Sequential
from keras.callbacks import EarlyStopping
import h5py # for model.save_weights

import data_utils as data_utils
import graph_utils as graph_utils
import metrics as metrics

def build_model(sequence_length):
  model = Sequential()
  in_out_neurons = 1
  hidden_neurons = sequence_length
  hidden2_neurons = sequence_length * 2

  model.add(LSTM(
    input_dim=in_out_neurons,
    output_dim=hidden_neurons,
    return_sequences=True))
  model.add(Dropout(0.2))

  model.add(LSTM(
    input_dim=hidden_neurons,
    output_dim=hidden2_neurons,
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

def run(epochs=1, sequence_length=50, ratio=0.5, is_daily=False):
  global_start_time = time.time()

  print('Loading data...')
  X_train, y_train, X_test, y_test = data_utils.power_consumption(sequence_length, ratio, is_daily)

  print('Compiling model...')

  model = build_model(sequence_length)

  print('Fitting data...')
  try:
    early_stopping = EarlyStopping(monitor='val_loss', patience=2)
    model.fit(X_train, y_train, batch_size=100, nb_epoch=epochs, validation_split=0.05, show_accuracy=True, callbacks=[early_stopping])
    predictions = model.predict(X_test)
    predictions = np.reshape(predictions, (predictions.size,))
  except KeyboardInterrupt:
    print('Training duration (s) : ', time.time() - global_start_time)
    return model, y_test, 0

  print('Training duration (s) : ', time.time() - global_start_time)
  return model, y_test, predictions

def main():
  model, y_test, predictions = run()

  # save for later use
  model.save_weights('../output/lstm.h5', overwrite=True)

  graph_utils.plot('lstm', predictions, y_test)

  # xRMSE: 0.2616
  print('RMSE: %.4f'% metrics.rmse(predictions, y_test))

  # MAPE: 0.0180
  print('MAPE: %.4f'% metrics.mape(predictions, y_test))

if __name__ == '__main__':
  main()
