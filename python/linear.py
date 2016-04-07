import matplotlib.pyplot as plt
import numpy as np
import time
import data_utils as data_utils
import graph_utils as graph_utils
import metrics as metrics

from sklearn.linear_model import LinearRegression

def run(sequence_length=50, ratio=0.5):
  global_start_time = time.time()

  print('Loading data...')
  X_train, y_train, X_test, y_test = data_utils.power_consumption(sequence_length, ratio)
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
  # minute
  y_test, predictions = run()
  # hourly
  # y_test, predictions = run(50, 1.0)
  # daily
  # y_test, predictions = run(50, 1.0)

  graph_utils.plot('linear', predictions, y_test)

  print('RMSE: %.4f'% metrics.rmse(predictions, y_test))

  print('MAPE: %.4f'% metrics.mape(predictions, y_test))

  # minute
  # RMSE: 0.2632
  # MAPE: 27.4989

  # hourly
  # RMSE: 31.4895
  # MAPE: 205.8636

  # daily
  # RMSE: 528.7838
  # MAPE: 185.3956

if __name__ == '__main__':
  main()
