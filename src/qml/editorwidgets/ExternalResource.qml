import QtQuick 2.5
import QtQuick.Controls 2.0
import org.qgis 1.0
import Theme 1.0
import ".." as QField
import QtQuick.Window 2.2

import org.qfield 1.0

Item {
  signal valueChanged(var value, bool isNull)

  anchors.left: parent.left
  anchors.right: parent.right

  height: Math.max(image.height, button_camera.height, button_gallery.height)

  property PictureSource __pictureSource

  ExpressionUtils {
    id: expressionUtils
    feature: currentFeature
    layer: currentLayer
    expressionText: JSON.parse(currentLayer.customProperty('QFieldSync/photo_naming'))[field.name]
  }

  Image {
    property var currentValue: value

    id: image
    width: 200 * dp
    autoTransform: true
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignLeft

    //source is managed over onCurrentValueChanged since the binding would break somewhere
    source: Theme.getThemeIcon("ic_photo_notavailable_white_48dp")

    MouseArea {
      anchors.fill: parent

      onClicked: {
        if (image.currentValue && settings.value("useNativeCamera", false))
          platformUtilities.open(image.currentValue, "image/*");
      }
    }

    onCurrentValueChanged: {
      if (image.status === Image.Error) {
        image.source=Theme.getThemeIcon("ic_broken_image_black_24dp")
      } else if (image.currentValue) {
        image.source= 'file://' + qgisProject.homePath + '/' + image.currentValue
      } else {
        image.source=Theme.getThemeIcon("ic_photo_notavailable_white_48dp")
      }
    }
  }

  QField.Button {
    id: button_camera
    width: 36 * dp
    height: 36 * dp

    anchors.right: button_gallery.left
    anchors.bottom: parent.bottom

    bgcolor: "transparent"

    onClicked: {
        if ( settings.valueBool("useNativeCamera", true) ) {
            var filepath = expressionUtils.evaluate()
            if( !filepath )
                filepath = 'DCIM/JPEG_'+(new Date()).toISOString().replace(/[^0-9]/g, "")+'.jpg'
            __pictureSource = platformUtilities.getCameraPicture(qgisProject.homePath+'/',filepath)
        } else {
            platformUtilities.createDir( qgisProject.homePath, 'DCIM' )
            camloader.active = true
        }
    }

    iconSource: Theme.getThemeIcon("ic_camera_alt_border_24dp")
  }

  QField.Button {
    id: button_gallery
    width: 36 * dp
    height: 36 * dp

    anchors.right: parent.right
    anchors.bottom: parent.bottom

    bgcolor: "transparent"

    onClicked: {
        var filepath = expressionUtils.evaluate()
        if( !filepath )
            filepath = 'DCIM/JPEG_'+(new Date()).toISOString().replace(/[^0-9]/g, "")+'.jpg'
        __pictureSource = platformUtilities.getGalleryPicture(qgisProject.homePath+'/', filepath)
    }

    iconSource: Theme.getThemeIcon("baseline_photo_library_black_24")
  }


  Loader {
    id: camloader
    sourceComponent: camcomponent
    active: false
  }

  Component {
    id: camcomponent

    Popup {
      id: campopup

      Component.onCompleted: {
        if ( platformUtilities.checkCameraPermissions() )
          open()
      }

      parent: ApplicationWindow.overlay

      x: 0
      y: 0
      height: parent.height
      width: parent.width

      modal: true
      focus: true

      QField.QFieldCamera {
        id: qfieldCamera

        visible: true

        onFinished: {
            Project.re
            var filepath = expressionUtils.evaluate()
            if( !filepath )
                filepath = 'DCIM/JPEG_'+(new Date()).toISOString().replace(/[^0-9]/g, "")+'.jpg'
            platformUtilities.renameFile( path, qgisProject.homePath +'/' + filepath)
            valueChanged(filepath, false)
            campopup.close()
        }
        onCanceled: {
          campopup.close()
        }
      }
      onClosed: camloader.active = false
    }
  }

  Connections {
    target: __pictureSource
    onPictureReceived: {
      valueChanged(path, false)
    }
  }
}
