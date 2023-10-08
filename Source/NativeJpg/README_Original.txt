Readme for NativeJpg
====================
Date: 20apr2011
Author: Nils Haeck

About NativeJpg
===============

This is a small-footprint native Object Pascal (Delphi) implementation 
to read and write Jpeg files. It provides a fully object-oriented approach
to working with Jpeg files, with clearly defined properties, events and methods.

You can use this code to read and write Jpeg documents from/to files or streams,
generate bitmaps from the compressed data and vice versa. It also provides for
methods to access the meta data in the files, and methods to manipulate the Jpeg
file in a lossless way (rotation/flipping, etc).

Compatibility:
=============
- Delphi5 through DelphiXE 
- Free Pascal (FPC) + Lazarus

Delphi packages:
===============
- tested with D7 and DXE. You can install this package but it is not necessary. These packages are merely for me to test if they are complete.

If you are a user of DtpDocuments, then please do not install NativeJpg. It is already part of DtpDocuments.

Open Source
===========
NativeJpg is open-source, with a very liberal license. See LICENSE in the distribution.
Copyright: Nils Haeck, SimDesign BV

If NativeJpg is helpful for you, then please consider to make a donation. See:
http://www.simdesign.nl/nativejpg.html


Class Tree:
==========

TDebugPersistent                           (sdDebug.pas)
  TsdJpegCoder                             (sdJpegCoder.pas)
    TsdJpegBlockCoder                      (sdJpegCoder.pas)
      TsdJpegBaselineCoder                 (sdJpegCoder.pas)
        TsdJpegProgressiveCoder            (sdJpegCoder.pas)
      TsdJpegExtendedCoder                 (sdJpegCoder.pas)

TDebugComponent                            (sdDebug.pas)
  TsdJpegImage                             (sdJpegImage.pas)

TDebugPersistent
  TsdJpegSaveOptions                       (sdJpegImage.pas)

TDebugPersistent
  TsdJpegMarker                            (sdJpegMarkers.pas)
    TsdAPPnMarker
      TsdJFIFMarker
      TsdAVI1Marker
      TsdICCProfileMarker
      TsdEXIFMarker
      TsdG3FAXMarker
      TsdIPTCMarker
      TsdAdobeApp14Marker
    TsdDHTMarker
    TsdDQTMarker
    TsdDRIMarker
    TsdSOFnMarker
    TsdSOSMarker
    TsdSOIMarker
    TsdEOIMarker
    TsdRSTMarker
    TsdDNLMarker
    TsdCOMMarker

TPersistent
  TsdJpegICCProfile                        (sdJpegMarkers.pas)

TDebugPersistent
  TsdBitReader                             (sdJpegBitstream.pas)
    TsdMemoryBitReader
    TsdStreamBitReader

TDebugPersistent
  TsdBitWriter =                           (sdJpegBitstream.pas)
    TsdDryRunBitWriter

TDebugPersistent
  TsdEntropyCoder                          (sdJpegHuffman.pas)
    TsdHuffmanCoder                        (sdJpegHuffman.pas)
      TsdHuffmanDecoder                    (sdJpegHuffman.pas)
        Tsd8bitHuffmanDecoder              (sdJpegHuffman.pas)
          TsdDCBaselineHuffmanDecoder      (sdJpegHuffman.pas)
            TsdDCProgressiveHuffmanDecoder (sdJpegHuffman.pas)
          TsdACBaselineHuffmanDecoder      (sdJpegHuffman.pas)
            TsdACProgressiveHuffmanDecoder (sdJpegHuffman.pas)
      Tsd8bitHuffmanEncoder                (sdJpegHuffman.pas)
        TsdDCBaselineHuffmanEncoder        (sdJpegHuffman.pas)
        TsdACBaselineHuffmanEncoder        (sdJpegHuffman.pas)

TDebugPersistent
  TsdLosslessOperation                     (sdJpegLossless.pas)


Separation of storage and visualisation
=======================================

Storage methods:

  TsdJpegImage.LoadFromStream
  TsdJpegImage.SaveToStream

Visualisation methods:

  TsdJpegImage.LoadJpeg
  TsdJpegImage.LoadTileBlock
  TsdJpegImage.SaveJpeg


Color space and conventional markers
====================================

  For Info on colorspace transformation and conventional markers this
  info can be helpful, but Simdesigns implementation might divert:

  "Colorspace Transformations and Conventional Markers

  Colorspace transformations are controlled by the destination type for both
  reading and writing of images. When Rasters are read, no colorspace transformation
  is performed, and any destination type is ignored. A warning is sent to any
  listeners if a destination type is specified in this case. When Rasters are
  written, any destination type is used to interpret the bands. This might result
  in a JFIF or Adobe header being written, or different component ids being written
  to the frame and scan headers. If values present in a metadata object do not match
  the destination type, the destination type is used and a warning is sent to any
  listeners.

  When reading, the contents of the stream are interpreted by the usual JPEG
  conventions, as follows:

    * If a JFIF APP0 marker segment is present, the colorspace is known to be
      either grayscale or YCbCr. If an APP2 marker segment containing an embedded
      ICC profile is also present, then the YCbCr is converted to RGB according
      to the formulas given in the JFIF spec, and the ICC profile is assumed to
      refer to the resulting RGB space.

    * If an Adobe APP14 marker segment is present, the colorspace is determined
      by consulting the transform flag. The transform flag takes one of three values:
          o 2 - The image is encoded as YCCK (implicitly converted from CMYK on encoding).
          o 1 - The image is encoded as YCbCr (implicitly converted from RGB on encoding).
          o 0 - Unknown. 3-channel images are assumed to be RGB, 4-channel images
                are assumed to be CMYK.

    * If neither marker segment is present, the following procedure is followed:
      Single-channel images are assumed to be grayscale, and 2-channel images are
      assumed to be grayscale with an alpha channel. For 3- and 4-channel images,
      the component ids are consulted. If these values are 1-3 for a 3-channel image,
      then the image is assumed to be YCbCr. If these values are 1-4 for a 4-channel
      image, then the image is assumed to be YCbCrA. If these values are > 4, they
      are checked against the ASCII codes for 'R', 'G', 'B', 'A', 'C', 'c'. These
      can encode the following colorspaces:


      RGB
      RGBA
      YCC (as 'Y','C','c'), assumed to be PhotoYCC
      YCCA (as 'Y','C','c','A'), assumed to be PhotoYCCA

      Otherwise, 3-channel subsampled images are assumed to be YCbCr, 3-channel
      non-subsampled images are assumed to be RGB, 4-channel subsampled images
      are assumed to be YCCK, and 4-channel, non-subsampled images are assumed
      to be CMYK.

    * All other images are declared uninterpretable and an exception is thrown
      if an attempt is made to read one as a BufferedImage. Such an image may be
      read only as a Raster. If an image is interpretable but there is no Java
      ColorSpace available corresponding to the encoded colorspace (e.g. YCbCr),
      then ImageReader.getRawImageType will return null.

  Once an encoded colorspace is determined, then the target colorspace is determined
  as follows:

    * If a destination type is not set, then the following default transformations
      take place after upsampling: YCbCr (and YCbCrA) images are converted to RGB
      (and RGBA) using the conversion provided by the underlying IJG library and
      either the built-in sRGB ColorSpace or a custom RGB ColorSpace object based
      on an embedded ICC profile is used to create the output ColorModel. PhotoYCC
      and PhotoYCCA images are not converted. CMYK and YCCK images are currently
      not supported.
    * If a destination image or type is set, it is used as follows: If the IJG
      library provides an appropriate conversion, it is used. Otherwise the default
      library conversion is followed by a colorspace conversion in Java.
    * Bands are selected AFTER any library colorspace conversion. If a subset of
      either source or destination bands is used, then the default library conversions
      are used with no further conversion in Java, regardless of any destination type.
    * An exception is thrown if an attempt is made to read an image in an unsupported
      jpeg colorspace as a BufferedImage (e.g. CMYK). Such images may be read as
      Rasters. If an image colorspace is unsupported or uninterpretable, then
      ImageReader.getImageTypes will return an empty Iterator. If a subset of the
      raw bands are required, a Raster must be obtained first and the bands obtained
      from that.

  For writing, the color transformation to apply is determined as follows:

  If a subset of the source bands is to be written, no color conversion is performed.
  Any destination, if set, must match the number of bands that will be written, and
  serves as an interpretation of the selected bands, rather than a conversion request.
  This behavior is identical to that for Rasters. If all the bands are to be written
  and an image (as opposed to a Raster) is being written, any destination type is
  ignored and a warning is sent to any listeners.

  If a destination type is used and any aspect of the metadata object, if there is
  one, is not compatible with that type, the destination type is used, the metadata
  written is modified from that provided, and a warning is sent to listeners. This
  includes the app0JFIF and app14Adobe nodes. The component ids in the sof and sos
  nodes are not modified, however, as unless a app0JFIF node is present, any values
  may be used.

  When a full image is written, a destination colorspace will be chosen based on
  the image contents and the metadata settings, according to the following algorithm:

  If no metadata object is specified, then the following defaults apply:

    * Grayscale images are written with a JFIF APP0 marker segment. Grayscale
      images with alpha are written with no special marker. As required by JFIF,
      the component ids in the frame and scan header is set to 1.
    * RGB images are converted to YCbCr, subsampled in the chrominance channels
      by half both vertically and horizontally, and written with a JFIF APP0 marker
      segment. If the ColorSpace of the image is based on an ICCProfile (it is an
      instance of ICC_ColorSpace, but is not one of the standard built-in
      ColorSpaces), then that profile is embedded in an APP2 marker segment. As
      required by JFIF, the component ids in the frame and scan headers are set
      to 1, 2, and 3.
    * RGBA images are converted to YCbCrA, subsampled in the chrominance channels
      by half both vertically and horizontally, and written without any special
      marker segments. The component ids in the frame and scan headers are set
      to 1, 2, 3, and 4.
    * PhotoYCC and YCCAimages are subsampled by half in the chrominance channels
      both vertically and horizontally and written with an Adobe APP14 marker
      segment and 'Y','C', and 'c' (and 'A' if an alpha channel is present) as
      component ids in the frame and scan headers.

  Default metadata objects for these image types will reflect these settings.

  If a metadata object is specified, then the number of channels in the frame and
  scan headers must always match the number of bands to be written, or an exception
  is thrown. app0JFIF and app14Adobe nodes may appear in the same metadata object
  only if the app14Adobe node indicates YCbCr, and the component ids are JFIF
  compatible (0-2). The various image types are processed in the following ways:
  (All multi-channel images are subsampled according to the sampling factors in the
  frame header node of the metadata object, regardless of color space.)

    * Grayscale Images:
          o If an app0JFIF node is present in the metadata object, a JFIF APP0
            marker segment is written.
          o If an app14Adobe node is present in the metadata object, it is checked
            for validity (transform must be UNKNOWN) and written.
          o If neither node is present in the metadata object, no special marker
            segment is written.
    * Grayscale Images with an Alpha Channel:
          o If an app0JFIF node is present in the metadata object, it is ignored
            and a warning is sent to listeners, as JFIF does not support 2-channel
            images.
          o If an app14Adobe node is present in the metadata object, it is checked
            for validity (transform must be UNKNOWN) and written. If transform is
            not UNKNOWN, a warning is sent to listeners and the correct transform
            is written.
          o If neither node is present in the metadata object, no special marker
            segment is written.
    * RGB Images:
          o If an app0JFIF node is present in the metadata object, the image is
            converted to YCbCr and written with a JFIF APP0 marker segment. If
            the ColorSpace of the image is based on a non-standard ICC Profile,
            then that profile is embedded in an APP2 marker segment. If the
            ColorSpace is not based on a non-standard ICC Profile, but an app2ICC
            node appears in the metadata, then an APP2 marker segment is written
            with the appropriate standard profile. Note that the profile must
            specify an RGB color space, as the file must be JFIF compliant.
          o If an app14Adobe node is present in the metadata object, the image is
            converted according to the color transform setting and written with
            an Adobe APP14 marker segment. Component ids are written just as they
            appear in the frame and scan headers. The color transform must be either
            YCbCr or UNKNOWN. If it is UNKNOWN, the image is not color converted.
          o If neither node is present, the component ids in the frame header are
            consulted. If these indicate a colorspace as described above, then the
            image is converted to that colorspace if possible. If the component ids
            do not indicate a colorspace, then the sampling factors are consulted.
            If the image is to be subsampled, it is converted to YCbCr first. If
            the image is not to be subsampled, then no conversion is applied. No
            special marker segmentss are written.
    * RGBA images:
          o If an app0JFIF node is present in the metadata object, it is ignored
            and a warning is sent to listeners, as JFIF does not support 4-channel
            images.
          o If an app14Adobe node is present in the metadata object, the image is
            written with an Adobe APP14 marker segment. No colorspace conversion
            is performed. Component ids are written just as they appear in the
            frame and scan headers. The color transform must be UNKNOWN. If it
            is not, a warning is sent to listeners.
          o If no app14Adobe node is present, the component ids in the frame header
            are consulted. If these indicate a colorspace as described above, then
            the image is converted to that colorspace if possible. If the component
            ids do not indicate a colorspace, then the sampling factors are
            consulted. If the image is to be subsampled, it is converted to YCbCrA.
            If the image is not to be subsampled, then no conversion is applied.
            No special marker segments are written.
    * PhotoYCC Images:
          o If an app0JFIF node is present in the metadata object, the image is
            converted to sRGB, and then to YCbCr during encoding, and a JFIF APP0
            marker segment is written.
          o If an app14Adobe node is present in the metadata object, no conversion
            is applied, and an Adobe APP14 marker segment is written. The color
            transform must be YCC. If it is not, a warning is sent to listeners.
          o If neither node is present in the metadata object, no conversion is
            applied, and no special marker segment is written.
    * PhotoYCCA Images:
          o If an app0JFIF node is present in the metadata object, it is ignored
            and a warning is sent to listeners, as JFIF does not support 4-channel
            images.
          o If an app14Adobe node is present in the metadata object, no conversion
            is applied, and an Adobe APP14 marker segment is written. The color
            transform must be UNKNOWN. If it is not, a warning is sent to listeners.
          o If neither node is present in the metadata object, no conversion is
            applied, and no special marker segment is written."

  http://java.sun.com/javase/6/docs/api/javax/imageio/metadata/doc-files/jpeg_metadata.html#color

