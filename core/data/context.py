
from dispatch import Signal


class DataNode(object):
    
    PATH_SEP = '.'

    def __init__(context=None):
        self.name = ""
        self._parentObject = None
        self._dataProperty = None
        self._value = None
        self._children = list()
        self.value = context
        self.valueChanged = Signal()
    
    #############parent object decorator######################
    def setParentObject(value):
        if value == self._parentObject:
            return self
        self._parentObject = value
        self.updateContent()
        return self

    @property
    def parentObject(self):
        return self._parentObject
    
    @parentObject.setter
    def parentObject(self, value):
        return self.setParentObject(value)

    #############data property decorator######################
    def setDataProperty(self, p):
        if p == self._dataProperty:
            return self
        if self._dataProperty:
            self._dataProperty.onPropertyValueChanaged.disconnect(self.onPropertyValueChanged)
        self._dataProperty = p
        if self._dataProperty:
            self._dataProperty.onPropertyValueChanaged.connect(self.onPropertyValueChanged)
        return self

    @property
    def dataProperty(self):
        return self._dataProperty
    
    @dataProperty.setter
    def dataProperty(self, p):
        return self.setDataProperty(p)
    
    #############children decorator######################

    def setChildren(children):
        self._children = children
        return self

    @property
    def children(self):
        return self._children

    @children.setter
    def children(self, newChildren):
        return self.setChildren(newChildren)
    
    #############value decorator######################


    def setValue(self, newValue):
        if newValue == self._value:
            return self
        self._value = newValue
        self.onValueChanged(self._value)
        for child in self.children:
            child.parentObject = self._value
        return self

    @property
    def value(self):
        return self._value
    
    @value.setter
    def value(self, newValue):
        return self.setValue(newValue)


    def onPropertyValueChanged(sender, **kwargs):
        value = kwargs.get('value', None)
        if value is not None:
            self.value = value

    def onValueChanged(obj):
        self.valueChanged.send(sender=self)



    def createChild(name):
        childNode = DataNode().setName(name).setParentObject(self.value)
        childNode.updateContent()
        self.children.append(childNode)
        return childNode

    def getChild(name):
        for child in self.children:
            if child.name == name:
                return child
        return self.createChild(name)


    def findDescendant(path):
        idx = path.find(PATH_SEP)
        if idx == -1:
            return self.getChild(path)
        else:
            return self.getChild(path[:idx]).findDescendant(path[idx+1:])






class Context(object):

    def __init__(self):
        self.root = DataNode(self)

    def registerListener(path, onValueChanged):
        node = self.root.findDescendant(path)
        if node is None:
            raise Exception("Invalid path '" + path + "' for type " + self.getType(), "path")
        node.valueChanged.connect(onValueChanged)
        return node.value

    def removeListener(path, onValueChanged):
        node = self.root.findDescendant(path)
        if node is None:
            raise Exception("Invalid path '" + path + "' for type " + self.getType(), "path")
        node.valueChanged.disconnect(onValueChanged)


    def setValue(path, value):
        node = self.root.findDescendant(path)
        if node is None:
            raise Exception("Invalid path '" + path + "' for type " + self.getType(), "path")
        node.setValue(value)

