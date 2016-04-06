import numpy as  np

from sklearn import metrics

def mape(predictions, true_labels):
  return np.mean(np.abs(predictions - true_labels) / true_labels)

def rmse(predictions, true_labels):
  return metrics.mean_squared_error(predictions, true_labels) ** 0.5
