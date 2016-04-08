import numpy as  np

from sklearn import metrics

def mape(predictions, true_labels):
  return np.mean(np.abs((true_labels - predictions) / true_labels)) * 100

def rmse(predictions, true_labels):
  return metrics.mean_squared_error(true_labels, predictions) ** 0.5
