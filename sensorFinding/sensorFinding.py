from os import listdir
from os.path import isfile
import numpy as np
from sklearn import svm, metrics
import math
from matplotlib import pyplot as plt

resizedDefaultSensorPath = 'training_data/defaultSensors'
resizedNotSensorPath = 'training_data/notSensors'

def copyResizedImages(defaultSensorImagesPath, notSensorImagesPath):
    defaultSensorImages = getImageFullPathsSub(defaultSensorImagesPath)

    notSensorImages = getImageFullPathsSub(notSensorImagesPath)

    new_size = 30

    sized_images = resizeImages(new_size, defaultSensorImages)
	
    sized_images_not_sensor = resizeImages(new_size, notSensorImages)

    saveImages(resizedDefaultSensorPath, [os.path.basename(f) for f in defaultSensorImages], sized_images)

    saveImages(resizedNotSensorPath, [os.path.basename(f) for f in notSensorImages], sized_images_not_sensor)

from os.path import join
def getImageFullPathsSub(basepath):
    return [join(basepath, f) for f in listdir(basepath) if not f.find('png') == -1]

from scipy import misc
useGrayScale = True
def resizeImages(newSize, images):
    return [misc.imresize(misc.imread(i, useGrayScale), (newSize, newSize), 'cubic') for i in images]

def saveImages(path, imageNames, images):
    if os.path.exists(path):
        os.rmdir(path)

    os.mkdir(path)

    tpls = zip(imageNames, images)
    for n, i in tpls:
        misc.imsave(os.path.join(path, n), i)

    return

def loadImages(basepath):
    imageFullPaths = getImageFullPathsSub(basepath)
    return [misc.imread(i, True) for i in imageFullPaths]

def loadDataSet():
    def loadImages_training(path, classification): 
        data = np.asarray(loadImages(path))
        data = data.reshape(len(data), -1)
        target = np.ones(len(data)) * classification
        return (data, target)

    (data_def_sensors, target_def_sensors) = loadImages_training(resizedDefaultSensorPath, 1)
    (data_not_sensors, target_not_sensors) = loadImages_training(resizedNotSensorPath, 0)
    
    data = np.append(data_def_sensors, data_not_sensors, axis = 0)
    target = np.append(target_def_sensors, target_not_sensors, axis = 0)
    
    return (data, target)

def test():
    (data, target) = loadDataSet()
    classifier = svm.SVC(gamma = .001)

    num_samples = len(data)

    indices = np.arange(num_samples);
    training_indices = np.random.permutation(indices)[:math.floor(.75 * num_samples)]

    classifier = svm.SVC(gamma = .001)

    classifier.fit(data[training_indices], target[training_indices])

    test_indices = np.setxor1d(training_indices, indices)

    expected = target[test_indices]
    predicted = classifier.predict(data[test_indices])

    print("Classification report for classifier %s:\n%s\n"
                  % (classifier, metrics.classification_report(expected, predicted)))
    print("Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted))

    images_and_predictions = list(zip(data[test_indices], predicted))
    for index, (image, prediction) in enumerate(images_and_predictions[:4]):
        plt.subplot(2, 4, index + 5)
        plt.axis('off')
        plt.imshow(image.reshape(30,-1), cmap=plt.cm.gray_r, interpolation='nearest')
        plt.title('Prediction: %i' % prediction)

    plt.show()
