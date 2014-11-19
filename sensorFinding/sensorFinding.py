from os import listdir
from os.path import isfile

def copyResizedImages(defaultSensorImagesPath, notSensorImagesPath):
    defaultSensorImages = getImagesSub(defaultSensorImagesPath)

    notSensorImages = getImagesSub(notSensorImagesPath)

    new_size = 30

    sized_images = resizeImages(new_size, defaultSensorImages)
	
    sized_images_not_sensor = resizeImages(new_size, notSensorImages)

    saveImages('defaultSensors', [os.path.basename(f) for f in defaultSensorImages], sized_images)

    saveImages('notSensors', [os.path.basename(f) for f in notSensorImages], sized_images_not_sensor)

from os.path import join
def getImagesSub(basepath):
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
