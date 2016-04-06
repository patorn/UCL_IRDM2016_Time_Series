import matplotlib.pyplot as plt
import numpy as np
import time
from keras.layers.core import Dense, Activation, Dropout
from keras.layers.recurrent import LSTM
from keras.models import Sequential
import h5py # for model.save_weights

import data_utils as data_utils
import metrics as metrics

def build_model():
  model = Sequential()
  in_out_neurons = 1
  hidden_neurons = 50
  hidden2_neurons = 100

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
    input_dim=hidden2_neurons,
    output_dim=in_out_neurons))
  model.add(Activation("linear"))

  start = time.time()
  model.compile(loss="mse", optimizer="rmsprop")
  print("Compilation Time : ", time.time() - start)
  return model

def run_network(epochs=1, sequence_length=50, ratio=0.5, is_daily=False):
  global_start_time = time.time()

  print('Loading data...')
  X_train, y_train, X_test, y_test = data_utils.power_consumption(sequence_length, ratio, is_daily)

  print('Compiling model...')

  model = build_model()

  print('Fitting data...')
  try:
    model.fit(X_train, y_train, batch_size=512, nb_epoch=epochs, validation_split=0.05)
    predictions = model.predict(X_test)
  except KeyboardInterrupt:
    print('Training duration (s) : ', time.time() - global_start_time)
    return model, y_test, 0

  print('Training duration (s) : ', time.time() - global_start_time)
  return model, y_test, predictions

# Plot first 100 test data
def plot(predictions, true_labels):
  try:
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(true_labels[:100])
    plt.plot(predictions[:100])
    plt.savefig('output/lstm')
  except Exception as e:
    print(str(e))

def main():
  model, y_test, predictions = run_network()

  # save for later use
  model.save_weights('output/lstm.h5')

  plot(predictions, y_test)

  # RMSE: 0.2633
  print('RMSE: %.4f'% metrics.rmse(predictions, y_test))

  # MAPE: 0.0065
  print('MAPE: %.4f'% metrics.mape(predictions, y_test))

if __name__ == '__main__':
  main()
