import Image

from os import listdir
from os.path import isfile

def copyResizedImages(defaultSensorImagesPath, notSensorImagesPath):
	defaultSensorImages = getImagesSub(defaultSensorImagesPath)

	notSensorImages = getImagesSub(notSensorImagesPath);

	copyImagesAndResize(30, defaultSensorImages, 'defaultSensors')
	
	copyImagesAndResize(30, notSensorImages, 'notSensors')


def getImagesSub(basePath)
	return [f for f in listdir(basepath) if f.find('py') == -1]

def copyImagesAndResize(newSize, images, newPath)

