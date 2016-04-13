import matplotlib.pyplot as plt

# Plot first 100 test data
def plot(graph_name, predictions, true_labels):
  try:
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(true_labels[:100], label='Original Series') # np.concatenate((y_train, y_test[:100]))
    plt.plot(predictions[:100], label='Predictions') # np.concatenate((X_train, predictions[:100]))
    plt.legend(loc='upper right')
    plt.xlabel('Timestep')
    plt.ylabel('Global Active Power')
    plt.savefig('../output/' + graph_name)
    plt.close()
  except Exception as e:
    print(str(e))
