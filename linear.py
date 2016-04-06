import matplotlib.pyplot as plt
import numpy as np
import time
import data_utils as data_utils
import graph_utils as graph_utils
import metrics as metrics

from sklearn.linear_model import LinearRegression

def run(epochs=1, sequence_length=50, ratio=0.5, is_daily=False):
  global_start_time = time.time()

  print('Loading data...')
  X_train, y_train, X_test, y_test = data_utils.power_consumption(sequence_length, ratio, is_daily)
  X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1]))
  X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1]))

  print('Compiling model...')

  regressor = LinearRegression(normalize=True)

  print('Fitting data...')

  regressor.fit(X_train, y_train)
  predictions = regressor.predict(X_test)

  print('Training duration (s) : ', time.time() - global_start_time)
  return y_test, predictions

def main():
  y_test, predictions = run()

  graph_utils.plot('linear', predictions, y_test)

  # RMSE: 0.2633
  print('RMSE: %.4f'% metrics.rmse(predictions, y_test))

  # MAPE: 0.0065
  print('MAPE: %.4f'% metrics.mape(predictions, y_test))

if __name__ == '__main__':
  main()
