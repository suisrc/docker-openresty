-- FFI bindings to GraphicsMagick:
local ffi = require "ffi"
ffi.cdef
[[
// <h2>Description</h2>[\w\W]+?</div> | </pre>[\w\W]+?<pre [\w\W]+?> | <a [\w\W]+?> | </a>
//===================================================================================================
//===================================================================================================
//===================================================================================================
// Types: http://www.graphicsmagick.org/api/types.html

// typedef struct _MagickWand  MagickWand;
// typedef struct _DrawingWand DrawingWand;
// typedef struct _PixelWand   PixelWand;

typedef void MagickWand;
typedef void DrawingWand;
typedef void PixelWand;

typedef int size_t;
typedef int ssize_t;
typedef int ExceptionType;
typedef int MagickSizeType;
typedef unsigned int Quantum;
typedef unsigned int MagickPassFail;

typedef void FILE;
typedef void ImageInfo;
typedef void DrawInfo;

typedef enum
{
  UniformNoise,
  GaussianNoise,
  MultiplicativeGaussianNoise,
  ImpulseNoise,
  LaplacianNoise,
  PoissonNoise,
  /* Below added on 2012-03-17 */
  RandomNoise,
  UndefinedNoise
} NoiseType;

typedef enum               /*    Exif     /  Row 0   / Column 0 */
                           /* Orientation /  edge    /   edge   */
{                          /* ----------- / -------- / -------- */
  UndefinedOrientation,    /*      0      / Unknown  / Unknown  */
  TopLeftOrientation,      /*      1      / Left     / Top      */
  TopRightOrientation,     /*      2      / Right    / Top      */
  BottomRightOrientation,  /*      3      / Right    / Bottom   */
  BottomLeftOrientation,   /*      4      / Left     / Bottom   */
  LeftTopOrientation,      /*      5      / Top      / Left     */
  RightTopOrientation,     /*      6      / Top      / Right    */
  RightBottomOrientation,  /*      7      / Bottom   / Right    */
  LeftBottomOrientation    /*      8      / Bottom   / Left     */
} OrientationType;

typedef struct _ExceptionInfo
{
  ExceptionType severity;
  char *reason, *description;
  int error_number;
  char *module, *function;
  unsigned long line;
  unsigned long signature;
} ExceptionInfo;

typedef enum
{
  UndefinedChannel,
  RedChannel,     /* RGB Red channel */
  CyanChannel,    /* CMYK Cyan channel */
  GreenChannel,   /* RGB Green channel */
  MagentaChannel, /* CMYK Magenta channel */
  BlueChannel,    /* RGB Blue channel */
  YellowChannel,  /* CMYK Yellow channel */
  OpacityChannel, /* Opacity channel */
  BlackChannel,   /* CMYK Black (K) channel */
  MatteChannel,   /* Same as Opacity channel (deprecated) */
  AllChannels,    /* Color channels */
  GrayChannel     /* Color channels represent an intensity. */
} ChannelType;

typedef enum
{
  UndefinedMetric,
  MeanAbsoluteErrorMetric,
  MeanSquaredErrorMetric,
  PeakAbsoluteErrorMetric,
  PeakSignalToNoiseRatioMetric,
  RootMeanSquaredErrorMetric
} MetricType;

typedef enum
{
  UndefinedCompositeOp = 0,
  OverCompositeOp,
  InCompositeOp,
  OutCompositeOp,
  AtopCompositeOp,
  XorCompositeOp,
  PlusCompositeOp,
  MinusCompositeOp,
  AddCompositeOp,
  SubtractCompositeOp,
  DifferenceCompositeOp,
  MultiplyCompositeOp,
  BumpmapCompositeOp,
  CopyCompositeOp,
  CopyRedCompositeOp,
  CopyGreenCompositeOp,
  CopyBlueCompositeOp,
  CopyOpacityCompositeOp,
  ClearCompositeOp,
  DissolveCompositeOp,
  DisplaceCompositeOp,
  ModulateCompositeOp,
  ThresholdCompositeOp,
  NoCompositeOp,
  DarkenCompositeOp,
  LightenCompositeOp,
  HueCompositeOp,
  SaturateCompositeOp,
  ColorizeCompositeOp,
  LuminizeCompositeOp,
  ScreenCompositeOp,
  OverlayCompositeOp,
  CopyCyanCompositeOp,
  CopyMagentaCompositeOp,
  CopyYellowCompositeOp,
  CopyBlackCompositeOp,
  DivideCompositeOp,
  HardLightCompositeOp,
  ExclusionCompositeOp,
  ColorDodgeCompositeOp,
  ColorBurnCompositeOp,
  SoftLightCompositeOp,
  LinearBurnCompositeOp,
  LinearDodgeCompositeOp,
  LinearLightCompositeOp,
  VividLightCompositeOp,
  PinLightCompositeOp,
  HardMixCompositeOp
} CompositeOperator;

typedef enum
{
  UndefinedColorspace,
  RGBColorspace,         /* Plain old RGB colorspace */
  GRAYColorspace,        /* Plain old full-range grayscale */
  TransparentColorspace, /* RGB but preserve matte channel during quantize */
  OHTAColorspace,
  XYZColorspace,         /* CIE XYZ */
  YCCColorspace,         /* Kodak PhotoCD PhotoYCC */
  YIQColorspace,
  YPbPrColorspace,
  YUVColorspace,
  CMYKColorspace,        /* Cyan, magenta, yellow, black, alpha */
  sRGBColorspace,        /* Kodak PhotoCD sRGB */
  HSLColorspace,         /* Hue, saturation, luminosity */
  HWBColorspace,         /* Hue, whiteness, blackness */
  LABColorspace,         /* LAB colorspace not supported yet other than via lcms */
  CineonLogRGBColorspace,/* RGB data with Cineon Log scaling, 2.048 density range */
  Rec601LumaColorspace,  /* Luma (Y) according to ITU-R 601 */
  Rec601YCbCrColorspace, /* YCbCr according to ITU-R 601 */
  Rec709LumaColorspace,  /* Luma (Y) according to ITU-R 709 */
  Rec709YCbCrColorspace  /* YCbCr according to ITU-R 709 */
} ColorspaceType;

typedef enum
{
  UndefinedCompression,
  NoCompression,
  BZipCompression,
  FaxCompression,
  Group3Compression = FaxCompression,
  Group4Compression,
  JPEGCompression,
  LosslessJPEGCompression,
  LZWCompression,
  RLECompression,
  ZipCompression,
  LZMACompression,              /* Lempel-Ziv-Markov chain algorithm */
  JPEG2000Compression,          /* ISO/IEC std 15444-1 */
  JBIG1Compression,             /* ISO/IEC std 11544 / ITU-T rec T.82 */
  JBIG2Compression,             /* ISO/IEC std 14492 / ITU-T rec T.88 */
  ZSTDCompression,              /* Facebook's Zstandard compression */
  WebPCompression               /* Google's WebP compression */
} CompressionType;

typedef enum
{
  UndefinedDispose,
  NoneDispose,
  BackgroundDispose,
  PreviousDispose
} DisposeType;

typedef enum
{
  ForgetGravity,
  NorthWestGravity,
  NorthGravity,
  NorthEastGravity,
  WestGravity,
  CenterGravity,
  EastGravity,
  SouthWestGravity,
  SouthGravity,
  SouthEastGravity,
  StaticGravity
} GravityType;

typedef enum
{
  UndefinedInterlace,
  NoInterlace,
  LineInterlace,
  PlaneInterlace,
  PartitionInterlace
} InterlaceType;

typedef enum
{
  CharPixel,         /* Unsigned 8 bit 'unsigned char' */
  ShortPixel,        /* Unsigned 16 bit 'unsigned short int' */
  IntegerPixel,      /* Unsigned 32 bit 'unsigned int' */
  LongPixel,         /* Unsigned 32 or 64 bit (CPU dependent) 'unsigned long' */
  FloatPixel,        /* Floating point 32-bit 'float' */
  DoublePixel        /* Floating point 64-bit 'double' */
} StorageType;

typedef enum
{
  UndefinedIntent,
  SaturationIntent,
  PerceptualIntent,
  AbsoluteIntent,
  RelativeIntent
} RenderingIntent;

typedef enum
{
  UndefinedType,
  BilevelType,
  GrayscaleType,
  GrayscaleMatteType,
  PaletteType,
  PaletteMatteType,
  TrueColorType,
  TrueColorMatteType,
  ColorSeparationType,
  ColorSeparationMatteType,
  OptimizeType
} ImageType;

typedef enum
{
  UndefinedResolution,
  PixelsPerInchResolution,
  PixelsPerCentimeterResolution
} ResolutionType;

typedef enum
{
  UndefinedVirtualPixelMethod,
  ConstantVirtualPixelMethod,
  EdgeVirtualPixelMethod,
  MirrorVirtualPixelMethod,
  TileVirtualPixelMethod
} VirtualPixelMethod;

typedef enum
{
  UndefinedResource=0, /* Undefined value */
  DiskResource,        /* Pixel cache total disk space (Gigabytes) */
  FileResource,        /* Pixel cache number of open files (Files) */
  MapResource,         /* Pixel cache total file memory-mapping (Megabytes) */
  MemoryResource,      /* Maximum heap memory (e.g. malloc) allocations (Megabytes) */
  PixelsResource,      /* Maximum number of pixels in single image (Pixels) */
  ThreadsResource,     /* Maximum number of worker threads */
  WidthResource,       /* Maximum pixel width of an image (Pixels) */
  HeightResource,      /* Maximum pixel height of an image (Pixels) */
  ReadResource         /* Maximum amount of uncompressed file data which may be read */
} ResourceType;

typedef enum
{
  UndefinedMode,
  FrameMode,
  UnframeMode,
  ConcatenateMode
} MontageMode;

typedef enum
{
  UndefinedPreview = 0,
  RotatePreview,
  ShearPreview,
  RollPreview,
  HuePreview,
  SaturationPreview,
  BrightnessPreview,
  GammaPreview,
  SpiffPreview,
  DullPreview,
  GrayscalePreview,
  QuantizePreview,
  DespecklePreview,
  ReduceNoisePreview,
  AddNoisePreview,
  SharpenPreview,
  BlurPreview,
  ThresholdPreview,
  EdgeDetectPreview,
  SpreadPreview,
  SolarizePreview,
  ShadePreview,
  RaisePreview,
  SegmentPreview,
  SwirlPreview,
  ImplodePreview,
  WavePreview,
  OilPaintPreview,
  CharcoalDrawingPreview,
  JPEGPreview
} PreviewType;

typedef enum
{
  UndefinedFilter,
  PointFilter,
  BoxFilter,
  TriangleFilter,
  HermiteFilter,
  HanningFilter,
  HammingFilter,
  BlackmanFilter,
  GaussianFilter,
  QuadraticFilter,
  CubicFilter,
  CatromFilter,
  MitchellFilter,
  LanczosFilter,
  BesselFilter,
  SincFilter
} FilterTypes;

typedef struct _AffineMatrix
{
  double
    sx,
    rx,
    ry,
    sy,
    tx,
    ty;
} AffineMatrix;

typedef struct _PointInfo
{
  double
    x,
    y;
} PointInfo;

typedef enum
{
  UndefinedRule,
  EvenOddRule,
  NonZeroRule
} FillRule;

typedef enum
{
  UserSpace,
  UserSpaceOnUse,
  ObjectBoundingBox
} ClipPathUnits;

typedef enum
{
  PointMethod = 0,
  ReplaceMethod,
  FloodfillMethod,
  FillToBorderMethod,
  ResetMethod
} PaintMethod;

typedef enum
{
  NormalStretch,
  UltraCondensedStretch,
  ExtraCondensedStretch,
  CondensedStretch,
  SemiCondensedStretch,
  SemiExpandedStretch,
  ExpandedStretch,
  ExtraExpandedStretch,
  UltraExpandedStretch,
  AnyStretch
} StretchType;

typedef enum
{
  NormalStyle,
  ItalicStyle,
  ObliqueStyle,
  AnyStyle
} StyleType;

typedef enum
{
  DefaultPathMode,
  AbsolutePathMode,
  RelativePathMode
} PathMode;

typedef struct _PixelPacket
{
  Quantum
    red,
    green,
    blue,
    opacity;
} PixelPacket;

typedef enum
{
  UndefinedCap,
  ButtCap,
  RoundCap,
  SquareCap
} LineCap;

typedef enum
{
  UndefinedJoin,
  MiterJoin,
  RoundJoin,
  BevelJoin
} LineJoin;

typedef enum
{
  NoDecoration,
  UnderlineDecoration,
  OverlineDecoration,
  LineThroughDecoration
} DecorationType;

//===================================================================================================
//===================================================================================================
//===================================================================================================
// http://www.graphicsmagick.org/api/image.html


void InitializeMagick();
void DestroyMagick();


//===================================================================================================
//===================================================================================================
//===================================================================================================
// Magick Wand: http://www.graphicsmagick.org/wand/magick_wand.html

MagickWand *NewMagickWand();

MagickWand *CloneMagickWand( const MagickWand *wand );

void DestroyMagickWand( MagickWand *wand );

unsigned int MagickAdaptiveThresholdImage( MagickWand *wand, const unsigned long width,
                                           const unsigned long height, const long offset );

unsigned int MagickAddImage( MagickWand *wand, const MagickWand *add_wand );

unsigned int MagickAddNoiseImage( MagickWand *wand, const NoiseType noise_type );

unsigned int MagickAffineTransformImage( MagickWand *wand, const DrawingWand *drawing_wand );

unsigned int MagickAnnotateImage( MagickWand *wand, const DrawingWand *drawing_wand,
                                  const double x, const double y, const double angle,
                                  const char *text );

unsigned int MagickAnimateImages( MagickWand *wand, const char *server_name );

MagickWand *MagickAppendImages( MagickWand *wand, const unsigned int stack );

unsigned int MagickAutoOrientImage( MagickWand *wand,
                                    const OrientationType current_orientation,
                                    ExceptionInfo *exception );

MagickWand *MagickAverageImages( MagickWand *wand );

unsigned int MagickBlackThresholdImage( MagickWand *wand, const PixelWand *threshold );

unsigned int MagickBlurImage( MagickWand *wand, const double radius, const double sigma );

unsigned int MagickBorderImage( MagickWand *wand, const PixelWand *bordercolor,
                                const unsigned long width, const unsigned long height );

MagickPassFail MagickCdlImage( MagickWand *wand, const char *cdl );

unsigned int MagickCharcoalImage( MagickWand *wand, const double radius, const double sigma );

unsigned int MagickChopImage( MagickWand *wand, const unsigned long width,
                              const unsigned long height, const long x, const long y );

void MagickClearException( MagickWand *wand );

unsigned int MagickClipImage( MagickWand *wand );

unsigned int MagickClipPathImage( MagickWand *wand, const char *pathname,
                                  const unsigned int inside );

MagickWand *MagickCoalesceImages( MagickWand *wand );

unsigned int MagickColorFloodfillImage( MagickWand *wand, const PixelWand *fill,
                                        const double fuzz, const PixelWand *bordercolor,
                                        const long x, const long y );

unsigned int MagickColorizeImage( MagickWand *wand, const PixelWand *colorize,
                                  const PixelWand *opacity );

unsigned int MagickCommentImage( MagickWand *wand, const char *comment );

MagickWand *MagickCompareImageChannels( MagickWand *wand, const MagickWand *reference,
                                        const ChannelType channel, const MetricType metric,
                                        double *distortion );

MagickWand *MagickCompareImages( MagickWand *wand, const MagickWand *reference,
                                 const MetricType metric, double *distortion );

unsigned int MagickCompositeImage( MagickWand *wand, const MagickWand *composite_wand,
                                   const CompositeOperator compose, const long x,
                                   const long y );

unsigned int MagickContrastImage( MagickWand *wand, const unsigned int sharpen );

unsigned int MagickConvolveImage( MagickWand *wand, const unsigned long order,
                                  const double *kernel );

unsigned int MagickCropImage( MagickWand *wand, const unsigned long width,
                              const unsigned long height, const long x, const long y );

unsigned int MagickCycleColormapImage( MagickWand *wand, const long displace );

MagickWand *MagickDeconstructImages( MagickWand *wand );

const char *MagickDescribeImage( MagickWand *wand );

unsigned int MagickDespeckleImage( MagickWand *wand );

unsigned int MagickDisplayImage( MagickWand *wand, const char *server_name );

unsigned int MagickDisplayImages( MagickWand *wand, const char *server_name );

unsigned int MagickDrawImage( MagickWand *wand, const DrawingWand *drawing_wand );

unsigned int MagickEdgeImage( MagickWand *wand, const double radius );

unsigned int MagickEmbossImage( MagickWand *wand, const double radius, const double sigma );

unsigned int MagickEnhanceImage( MagickWand *wand );

unsigned int MagickEqualizeImage( MagickWand *wand );

unsigned int MagickExtentImage( MagickWand *wand, const size_t width, const size_t height,
                                const ssize_t x, const ssize_t y );

MagickWand *MagickFlattenImages( MagickWand *wand );

unsigned int MagickFlipImage( MagickWand *wand );

unsigned int MagickFlopImage( MagickWand *wand );

unsigned int MagickFrameImage( MagickWand *wand, const PixelWand *matte_color,
                               const unsigned long width, const unsigned long height,
                               const long inner_bevel, const long outer_bevel );

MagickWand *MagickFxImage( MagickWand *wand, const char *expression );

MagickWand *MagickFxImageChannel( MagickWand *wand, const ChannelType channel,
                                  const char *expression );

unsigned int MagickGammaImage( MagickWand *wand, const double gamma );

unsigned int MagickGammaImageChannel( MagickWand *wand, const ChannelType channel,
                                      const double gamma );

char *MagickGetConfigureInfo( MagickWand *wand, const char *name );

const char *MagickGetCopyright();

char *MagickGetException( const MagickWand *wand, ExceptionType *severity );

const char *MagickGetFilename( const MagickWand *wand );

const char *MagickGetHomeURL();

MagickWand *MagickGetImage( MagickWand *wand );

char *MagickGetImageAttribute( MagickWand *wand, const char *name );

unsigned int MagickGetImageBackgroundColor( MagickWand *wand, PixelWand *background_color );

unsigned int MagickGetImageBluePrimary( MagickWand *wand, double *x, double *y );

unsigned int MagickGetImageBorderColor( MagickWand *wand, PixelWand *border_color );

unsigned int MagickGetImageBoundingBox( MagickWand *wand, const double fuzz,
                                        unsigned long *width, unsigned long *height,
                                        long *x, long *y );

unsigned long MagickGetImageChannelDepth( MagickWand *wand, const ChannelType channel );

unsigned int MagickGetImageChannelExtrema( MagickWand *wand, const ChannelType channel,
                                           unsigned long *minima, unsigned long *maxima );

unsigned int MagickGetImageChannelMean( MagickWand *wand, const ChannelType channel,
                                        double *mean, double *standard_deviation );

unsigned int MagickGetImageColormapColor( MagickWand *wand, const unsigned long index,
                                          PixelWand *color );

unsigned long MagickGetImageColors( MagickWand *wand );

ColorspaceType MagickGetImageColorspace( MagickWand *wand );

CompositeOperator MagickGetImageCompose( MagickWand *wand );

CompressionType MagickGetImageCompression( MagickWand *wand );

unsigned long MagickGetImageDelay( MagickWand *wand );

unsigned long MagickGetImageDepth( MagickWand *wand );

unsigned int MagickGetImageExtrema( MagickWand *wand, unsigned long *min,
                                    unsigned long *max );

DisposeType MagickGetImageDispose( MagickWand *wand );

const char MagickGetImageFilename( MagickWand *wand );

const char MagickGetImageFormat( MagickWand *wand );

double MagickGetImageFuzz( MagickWand *wand );

double MagickGetImageGamma( MagickWand *wand );

GravityType MagickGetImageGravity( MagickWand *wand );

unsigned int MagickGetImageGreenPrimary( MagickWand *wand, double *x, double *y );

unsigned long MagickGetImageHeight( MagickWand *wand );

PixelWand *MagickGetImageHistogram( MagickWand *wand, unsigned long *number_colors );

unsigned int MagickGetImageIndex( MagickWand *wand );

InterlaceType MagickGetImageInterlaceScheme( MagickWand *wand );

unsigned long MagickGetImageIterations( MagickWand *wand );

unsigned int MagickGetImageMatteColor( MagickWand *wand, PixelWand *matte_color );

OrientationType MagickGetImageOrientation( MagickWand *wand );

void MagickGetImagePage( MagickWand *wand, unsigned long *width, unsigned long *height, long *x,
                    long *y );

unsigned int MagickGetImagePixels( MagickWand *wand, const long x_offset, const long y_offset,
                                   const unsigned long columns, const unsigned long rows,
                                   const char *map, const StorageType storage,
                                   unsigned char *pixels );

unsigned char *MagickGetImageProfile( MagickWand *wand, const char *name,
                                      unsigned long *length );

unsigned int MagickGetImageRedPrimary( MagickWand *wand, double *x, double *y );

RenderingIntent MagickGetImageRenderingIntent( MagickWand *wand );

unsigned int MagickGetImageResolution( MagickWand *wand, double *x, double *y );

unsigned long MagickGetImageScene( MagickWand *wand );

const char MagickGetImageSignature( MagickWand *wand );

MagickSizeType MagickGetImageSize( MagickWand *wand );

ImageType MagickGetImageType( MagickWand *wand );

ImageType MagickGetImageSavedType( MagickWand *wand );

ResolutionType MagickGetImageUnits( MagickWand *wand );

VirtualPixelMethod MagickGetImageVirtualPixelMethod( MagickWand *wand );

unsigned int MagickGetImageWhitePoint( MagickWand *wand, double *x, double *y );

unsigned long MagickGetImageWidth( MagickWand *wand );

unsigned long MagickGetNumberImages( MagickWand *wand );

const char *MagickGetPackageName();

const char *MagickGetQuantumDepth( unsigned long *depth );

const char *MagickGetReleaseDate();

unsigned long MagickGetResourceLimit( const ResourceType type );

double *MagickGetSamplingFactors( MagickWand *wand, unsigned long *number_factors );

unsigned int MagickGetSize( const MagickWand *wand, unsigned long *columns,
                            unsigned long *rows );

const char *MagickGetVersion( unsigned long *version );

MagickPassFail MagickHaldClutImage( MagickWand *wand, const MagickWand *clut_wand );

unsigned int MagickHasColormap( MagickWand *wand, unsigned int *colormap );

unsigned int MagickHasNextImage( MagickWand *wand );

unsigned int MagickHasPreviousImage( MagickWand *wand );

unsigned int MagickImplodeImage( MagickWand *wand, const double radius );

unsigned int MagickIsGrayImage( MagickWand *wand, unsigned int *grayimage );

unsigned int MagickIsMonochromeImage( MagickWand *wand, unsigned int *monochrome );

unsigned int MagickIsOpaqueImage( MagickWand *wand, unsigned int *opaque );

unsigned int MagickIsPaletteImage( MagickWand *wand, unsigned int *palette );

unsigned int MagickLabelImage( MagickWand *wand, const char *label );

unsigned int MagickLevelImage( MagickWand *wand, const double black_point, const double gamma,
                               const double white_point );

unsigned int MagickLevelImageChannel( MagickWand *wand, const ChannelType channel,
                                      const double black_point, const double gamma,
                                      const double white_point );

unsigned int MagickMagnifyImage( MagickWand *wand );

unsigned int MagickMapImage( MagickWand *wand, const MagickWand *map_wand,
                             const unsigned int dither );

unsigned int MagickMatteFloodfillImage( MagickWand *wand, const Quantum opacity,
                                        const double fuzz, const PixelWand *bordercolor,
                                        const long x, const long y );

unsigned int MagickMedianFilterImage( MagickWand *wand, const double radius );

unsigned int MagickMinifyImage( MagickWand *wand );

unsigned int MagickModulateImage( MagickWand *wand, const double brightness,
                                  const double saturation, const double hue );

MagickWand MagickMontageImage( MagickWand *wand, const DrawingWand* drawing_wand,
                               const char *tile_geometry, const char *thumbnail_geometry,
                               const MontageMode mode, const char *frame );

MagickWand *MagickMorphImages( MagickWand *wand, const unsigned long number_frames );

MagickWand *MagickMosaicImages( MagickWand *wand );

unsigned int MagickMotionBlurImage( MagickWand *wand, const double radius, const double sigma,
                                    const double angle );

unsigned int MagickNegateImage( MagickWand *wand, const unsigned int gray );

unsigned int MagickNegateImageChannel( MagickWand *wand, const ChannelType channel,
                                       const unsigned int gray );

unsigned int MagickNextImage( MagickWand *wand );

unsigned int MagickNormalizeImage( MagickWand *wand );

unsigned int MagickOilPaintImage( MagickWand *wand, const double radius );

unsigned int MagickOpaqueImage( MagickWand *wand, const PixelWand *target,
                                const PixelWand *fill, const double fuzz );

unsigned int MagickPingImage( MagickWand *wand, const char *filename );

MagickWand *MagickPreviewImages( MagickWand *wand, const PreviewType preview );

unsigned int MagickPreviousImage( MagickWand *wand );

unsigned int MagickProfileImage( MagickWand *wand, const char *name,
                                 const unsigned char *profile, const size_t length );

unsigned int MagickQuantizeImage( MagickWand *wand, const unsigned long number_colors,
                                  const ColorspaceType colorspace,
                                  const unsigned long treedepth, const unsigned int dither,
                                  const unsigned int measure_error );

unsigned int MagickQuantizeImages( MagickWand *wand, const unsigned long number_colors,
                                   const ColorspaceType colorspace,
                                   const unsigned long treedepth, const unsigned int dither,
                                   const unsigned int measure_error );

double *MagickQueryFontMetrics( MagickWand *wand, const DrawingWand *drawing_wand,
                                const char *text );

char ** MagickQueryFonts( const char *pattern, unsigned long *number_fonts );

char ** MagickQueryFormats( const char *pattern, unsigned long *number_formats );

unsigned int MagickRadialBlurImage( MagickWand *wand, const double angle );

unsigned int MagickRaiseImage( MagickWand *wand, const unsigned long width,
                               const unsigned long height, const long x, const long y,
                               const unsigned int raise_flag );

unsigned int MagickReadImage( MagickWand *wand, const char *filename );

unsigned int MagickReadImageBlob( MagickWand *wand, const unsigned char *blob,
                                  const size_t length );

unsigned int MagickReadImageFile( MagickWand *wand, FILE *file );

unsigned int MagickReduceNoiseImage( MagickWand *wand, const double radius );

unsigned int MagickRelinquishMemory( void *resource );

unsigned int MagickRemoveImage( MagickWand *wand );

unsigned int MagickRemoveImageOption( MagickWand *wand, const char *format,
                                      const char *key );

unsigned char *MagickRemoveImageProfile( MagickWand *wand, const char *name,
                                         unsigned long *length );

void MagickResetIterator( MagickWand *wand );

unsigned int MagickResampleImage( MagickWand *wand, const double x_resolution,
                                  const double y_resolution, const FilterTypes filter,
                                  const double blur );

unsigned int MagickResizeImage( MagickWand *wand, const unsigned long columns,
                                const unsigned long rows, const FilterTypes filter,
                                const double blur );

unsigned int MagickRollImage( MagickWand *wand, const long x_offset,
                              const unsigned long y_offset );

unsigned int MagickRotateImage( MagickWand *wand, const PixelWand *background,
                                const double degrees );

unsigned int MagickSampleImage( MagickWand *wand, const unsigned long columns,
                                const unsigned long rows );

unsigned int MagickScaleImage( MagickWand *wand, const unsigned long columns,
                               const unsigned long rows );

unsigned int MagickSeparateImageChannel( MagickWand *wand, const ChannelType channel );

unsigned int MagickSetCompressionQuality( MagickWand *wand, const unsigned long quality );

unsigned int MagickSetDepth( MagickWand *wand, const size_t depth );

unsigned int MagickSetFilename( MagickWand *wand, const char *filename );

unsigned int MagickSetFormat( MagickWand *wand, const char *format );

unsigned int MagickSetImage( MagickWand *wand, const MagickWand *set_wand );

unsigned int MagickSetImageAttribute( MagickWand *wand, const char *name,
                                      const char *value );

unsigned int MagickSetImageBackgroundColor( MagickWand *wand, const PixelWand *background );

unsigned int MagickSetImageBluePrimary( MagickWand *wand, const double x, const double y );

unsigned int MagickSetImageBorderColor( MagickWand *wand, const PixelWand *border );

unsigned int MagickSetImageColormapColor( MagickWand *wand, const unsigned long index,
                                          const PixelWand *color );

unsigned int MagickSetImageColorspace( MagickWand *wand, const ColorspaceType colorspace );

unsigned int MagickSetImageCompose( MagickWand *wand, const CompositeOperator compose );

unsigned int MagickSetImageCompression( MagickWand *wand,
                                        const CompressionType compression );

unsigned int MagickSetImageDelay( MagickWand *wand, const unsigned long delay );

unsigned int MagickSetImageChannelDepth( MagickWand *wand, const ChannelType channel,
                                         const unsigned long depth );

unsigned int MagickSetImageDepth( MagickWand *wand, const unsigned long depth );

unsigned int MagickSetImageDispose( MagickWand *wand, const DisposeType dispose );

unsigned int MagickSetImageFilename( MagickWand *wand, const char *filename );

unsigned int MagickSetImageFormat( MagickWand *wand, const char *format );

unsigned int MagickSetImageFuzz( MagickWand *wand, const double fuzz );

unsigned int MagickSetImageGamma( MagickWand *wand, const double gamma );

unsigned int MagickSetImageGravity( MagickWand *wand, const GravityType );

unsigned int MagickSetImageGreenPrimary( MagickWand *wand, const double x, const double y );

unsigned int MagickSetImageIndex( MagickWand *wand, const long index );

unsigned int MagickSetImageInterlaceScheme( MagickWand *wand,
                                            const InterlaceType interlace_scheme );

unsigned int MagickSetImageIterations( MagickWand *wand, const unsigned long iterations );

unsigned int MagickSetImageMatteColor( MagickWand *wand, const PixelWand *matte );

unsigned int MagickSetImageOption( MagickWand *wand, const char *format, const char *key,
                                   const char *value );

void MagickSetImageOrientation( MagickWand *wand, OrientationType new_orientation );

unsigned int MagickSetImagePage( MagickWand *wand, const unsigned long width,
                                 const unsigned long height, const long x, const long y );

unsigned int MagickSetImagePixels( MagickWand *wand, const long x_offset, const long y_offset,
                                   const unsigned long columns, const unsigned long rows,
                                   const char *map, const StorageType storage,
                                   unsigned char *pixels );

unsigned int MagickSetImageProfile( MagickWand *wand, const char *name,
                                    const unsigned char *profile,
                                    const unsigned long length );

unsigned int MagickSetImageRedPrimary( MagickWand *wand, const double x, const double y );

unsigned int MagickSetImageRenderingIntent( MagickWand *wand,
                                            const RenderingIntent rendering_intent );

unsigned int MagickSetImageResolution( MagickWand *wand, const double x_resolution,
                                       const double y_resolution );

unsigned int MagickSetImageScene( MagickWand *wand, const unsigned long scene );

unsigned int MagickSetImageType( MagickWand *wand, const ImageType image_type );

unsigned int MagickSetImageSavedType( MagickWand *wand, const ImageType image_type );

unsigned int MagickSetImageUnits( MagickWand *wand, const ResolutionType units );

unsigned int MagickSetImageVirtualPixelMethod( MagickWand *wand,
                                               const VirtualPixelMethod method );

unsigned int MagickSetInterlaceScheme( MagickWand *wand,
                                       const InterlaceType interlace_scheme );

unsigned int MagickSetResolution( MagickWand *wand, const double x_resolution,
                                  const double y_resolution );

unsigned int MagickSetResolutionUnits( MagickWand *wand, const ResolutionType units );

unsigned int MagickSetResourceLimit( const ResourceType type, const unsigned long *limit );

unsigned int MagickSetSamplingFactors( MagickWand *wand, const unsigned long number_factors,
                                       const double *sampling_factors );

unsigned int MagickSetSize( MagickWand *wand, const unsigned long columns,
                            const unsigned long rows );

unsigned int MagickSetImageWhitePoint( MagickWand *wand, const double x, const double y );

unsigned int MagickSetPassphrase( MagickWand *wand, const char *passphrase );

unsigned int MagickSharpenImage( MagickWand *wand, const double radius, const double sigma );

unsigned int MagickShaveImage( MagickWand *wand, const unsigned long columns,
                               const unsigned long rows );

unsigned int MagickShearImage( MagickWand *wand, const PixelWand *background,
                               const double x_shear, const double y_shear );

unsigned int MagickSolarizeImage( MagickWand *wand, const double threshold );

unsigned int MagickSpreadImage( MagickWand *wand, const double radius );

MagickWand *MagickSteganoImage( MagickWand *wand, const MagickWand *watermark_wand,
                                const long offset );

MagickWand *MagickStereoImage( MagickWand *wand, const MagickWand *offset_wand );

unsigned int MagickStripImage( MagickWand *wand );

unsigned int MagickSwirlImage( MagickWand *wand, const double degrees );

MagickWand *MagickTextureImage( MagickWand *wand, const MagickWand *texture_wand );

unsigned int MagickThresholdImage( MagickWand *wand, const double threshold );

unsigned int MagickThresholdImageChannel( MagickWand *wand, const ChannelType channel,
                                          const double threshold );

unsigned int MagickTintImage( MagickWand *wand, const PixelWand *tint,
                              const PixelWand *opacity );

MagickWand *MagickTransformImage( MagickWand *wand, const char *crop,
                                  const char *geometry );

unsigned int MagickTransparentImage( MagickWand *wand, const PixelWand *target,
                                     const unsigned int opacity, const double fuzz );

unsigned int MagickTrimImage( MagickWand *wand, const double fuzz );

unsigned int MagickUnsharpMaskImage( MagickWand *wand, const double radius, const double sigma,
                                     const double amount, const double threshold );

unsigned int MagickWaveImage( MagickWand *wand, const double amplitude,
                              const double wave_length );

unsigned int MagickWhiteThresholdImage( MagickWand *wand, const PixelWand *threshold );

unsigned int MagickWriteImage( MagickWand *wand, const char *filename );

unsigned int MagickWriteImagesFile( MagickWand *wand, FILE *file, const unsigned int adjoin );

unsigned char *MagickWriteImageBlob( MagickWand *wand, size_t *length );

unsigned int MagickWriteImageFile( MagickWand *wand, FILE *file );

unsigned int MagickWriteImages( MagickWand *wand, const char *filename,
                                const unsigned int adjoin );


//===================================================================================================
//===================================================================================================
//===================================================================================================
// Drawing Wand: http://www.graphicsmagick.org/wand/drawing_wand.html

DrawingWand *MagickNewDrawingWand( void );

DrawingWand *MagickCloneDrawingWand( const DrawingWand *drawing_wand );

void MagickDestroyDrawingWand( DrawingWand *drawing_wand );

void MagickDrawAnnotation( DrawingWand *drawing_wand, const double x, const double y,
                     const unsigned char *text );

void MagickDrawAffine( DrawingWand *drawing_wand, const AffineMatrix *affine );

DrawingWand *MagickDrawAllocateWand( const DrawInfo *draw_info, ImageInfo *image );

void MagickDrawArc( DrawingWand *drawing_wand, const double sx, const double sy, const double ex,
              const double ey, const double sd, const double ed );

void MagickDrawBezier( DrawingWand *drawing_wand, const unsigned long number_coordinates,
                 const PointInfo *coordinates );

void MagickDrawCircle( DrawingWand *drawing_wand, const double ox, const double oy, const double px,
                 const double py );

MagickPassFail MagickDrawClearException( DrawingWand *drawing_wand );

char *MagickDrawGetClipPath( const DrawingWand *drawing_wand );

void MagickDrawSetClipPath( DrawingWand *drawing_wand, const char *clip_path );

FillRule MagickDrawGetClipRule( const DrawingWand *drawing_wand );

void MagickDrawSetClipRule( DrawingWand *drawing_wand, const FillRule fill_rule );

ClipPathUnits MagickDrawGetClipUnits( const DrawingWand *drawing_wand );

char *MagickDrawGetException( const DrawingWand *drawing_wand, ExceptionType *severity );

void MagickDrawSetClipUnits( DrawingWand *drawing_wand, const ClipPathUnits clip_units );

void MagickDrawColor( DrawingWand *drawing_wand, const double x, const double y,
                const PaintMethod paintMethod );

void MagickDrawComment( DrawingWand *drawing_wand, const char *comment );

void MagickDrawEllipse( DrawingWand *drawing_wand, const double ox, const double oy, const double rx,
                  const double ry, const double start, const double end );

void MagickDrawGetFillColor( const DrawingWand *drawing_wand, PixelWand *fill_color );

void MagickDrawSetFillColor( DrawingWand *drawing_wand, const PixelWand *fill_wand );

void MagickDrawSetFillPatternURL( DrawingWand *drawing_wand, const char *fill_url );

double MagickDrawGetFillOpacity( const DrawingWand *drawing_wand );

void MagickDrawSetFillOpacity( DrawingWand *drawing_wand, const double fill_opacity );

FillRule MagickDrawGetFillRule( const DrawingWand *drawing_wand );

void MagickDrawSetFillRule( DrawingWand *drawing_wand, const FillRule fill_rule );

char *MagickDrawGetFont( const DrawingWand *drawing_wand );

void MagickDrawSetFont( DrawingWand *drawing_wand, const char *font_name );

char *MagickDrawGetFontFamily( const DrawingWand *drawing_wand );

void MagickDrawSetFontFamily( DrawingWand *drawing_wand, const char *font_family );

double MagickDrawGetFontSize( const DrawingWand *drawing_wand );

void MagickDrawSetFontSize( DrawingWand *drawing_wand, const double pointsize );

StretchType MagickDrawGetFontStretch( const DrawingWand *drawing_wand );

void MagickDrawSetFontStretch( DrawingWand *drawing_wand, const StretchType font_stretch );

StyleType MagickDrawGetFontStyle( const DrawingWand *drawing_wand );

void MagickDrawSetFontStyle( DrawingWand *drawing_wand, const StyleType style );

unsigned long MagickDrawGetFontWeight( const DrawingWand *drawing_wand );

void MagickDrawSetFontWeight( DrawingWand *drawing_wand, const unsigned long font_weight );

GravityType MagickDrawGetGravity( const DrawingWand *drawing_wand );

void MagickDrawSetGravity( DrawingWand *drawing_wand, const GravityType gravity );

void MagickDrawComposite( DrawingWand *drawing_wand, const CompositeOperator composite_operator,
                    const double x, const double y, const double width, const double height,
                    const ImageInfo *image );

void MagickDrawLine( DrawingWand *drawing_wand, const double sx, const double sy, const double ex,
               const double ey );

void MagickDrawMatte( DrawingWand *drawing_wand, const double x, const double y,
                const PaintMethod paint_method );

void MagickDrawPathClose( DrawingWand *drawing_wand );

void MagickDrawPathCurveToAbsolute( DrawingWand *drawing_wand, const double x1, const double y1,
                              const double x2, const double y2, const double x,
                              const double y );

void MagickDrawPathCurveToRelative( DrawingWand *drawing_wand, const double x1, const double y1,
                              const double x2, const double y2, const double x,
                              const double y );

void MagickDrawPathCurveToQuadraticBezierAbsolute( DrawingWand *drawing_wand, const double x1,
                                             const double y1, const double x, const double y );

void MagickDrawPathCurveToQuadraticBezierRelative( DrawingWand *drawing_wand, const double x1,
                                             const double y1, const double x,
                                             const double y );

void MagickDrawPathCurveToQuadraticBezierSmoothAbsolute( DrawingWand *drawing_wand, const double x,
                                                   const double y );

void MagickDrawPathCurveToQuadraticBezierSmoothRelative( DrawingWand *drawing_wand, const double x,
                                                   const double y );

void MagickDrawPathCurveToSmoothAbsolute( DrawingWand *drawing_wand, const double x2, const double y2,
                                    const double x, const double y );

void MagickDrawPathCurveToSmoothRelative( DrawingWand *drawing_wand, const double x2,
                                    const double y2, const double x, const double y );

void MagickDrawPathEllipticArcAbsolute( DrawingWand *drawing_wand, const double rx, const double ry,
                                  const double x_axis_rotation,
                                  unsigned int large_arc_flag, unsigned int sweep_flag,
                                  const double x, const double y );

void MagickDrawPathEllipticArcRelative( DrawingWand *drawing_wand, const double rx, const double ry,
                                  const double x_axis_rotation,
                                  unsigned int large_arc_flag, unsigned int sweep_flag,
                                  const double x, const double y );

void MagickDrawPathFinish( DrawingWand *drawing_wand );

void MagickDrawPathLineToAbsolute( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawPathLineToRelative( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawPathLineToHorizontalAbsolute( DrawingWand *drawing_wand, const PathMode mode,
                                       const double x );

void MagickDrawPathLineToHorizontalRelative( DrawingWand *drawing_wand, const double x );

void MagickDrawPathLineToVerticalAbsolute( DrawingWand *drawing_wand, const double y );

void MagickDrawPathLineToVerticalRelative( DrawingWand *drawing_wand, const double y );

void MagickDrawPathMoveToAbsolute( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawPathMoveToRelative( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawPathStart( DrawingWand *drawing_wand );

DrawInfo *MagickDrawPeekGraphicContext( const DrawingWand *drawing_wand );

void MagickDrawPoint( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawPolygon( DrawingWand *drawing_wand, const unsigned long number_coordinates,
                  const PointInfo *coordinates );

void MagickDrawPolyline( DrawingWand *drawing_wand, const unsigned long number_coordinates,
                   const PointInfo *coordinates );

void MagickDrawPopClipPath( DrawingWand *drawing_wand );

void MagickDrawPopDefs( DrawingWand *drawing_wand );

void MagickDrawPopGraphicContext( DrawingWand *drawing_wand );

void MagickDrawPopPattern( DrawingWand *drawing_wand );

void MagickDrawPushClipPath( DrawingWand *drawing_wand, const char *clip_path_id );

void MagickDrawPushDefs( DrawingWand *drawing_wand );

void MagickDrawPushGraphicContext( DrawingWand *drawing_wand );

void MagickDrawPushPattern( DrawingWand *drawing_wand, const char *pattern_id, const double x,
                      const double y, const double width, const double height );

void MagickDrawRectangle( DrawingWand *drawing_wand, const double x1, const double y1,
                    const double x2, const double y2 );

unsigned int MagickDrawRender( const DrawingWand *drawing_wand );

void MagickDrawRotate( DrawingWand *drawing_wand, const double degrees );

void MagickDrawRoundRectangle( DrawingWand *drawing_wand, double x1, double y1, double x2, double y2,
                         double rx, double ry );

void MagickDrawScale( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawSkewX( DrawingWand *drawing_wand, const double degrees );

void MagickDrawSkewY( DrawingWand *drawing_wand, const double degrees );

void MagickDrawSetStopColor( DrawingWand *drawing_wand, const PixelPacket *stop_color,
                       const double offset );

void MagickDrawGetStrokeColor( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeColor( DrawingWand *drawing_wand, const PixelWand *stroke_wand );

void MagickDrawSetStrokePatternURL( DrawingWand *drawing_wand, const char *stroke_url );

unsigned int MagickDrawGetStrokeAntialias( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeAntialias( DrawingWand *drawing_wand,
                             const unsigned int stroke_antialias );

double *MagickDrawGetStrokeDashArray( const DrawingWand *drawing_wand,
                                unsigned long *number_elements );

void MagickDrawSetStrokeDashArray( DrawingWand *drawing_wand, const unsigned long number_elements,
                             const double *dash_array );

double MagickDrawGetStrokeDashOffset( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeDashOffset( DrawingWand *drawing_wand, const double dash_offset );

LineCap MagickDrawGetStrokeLineCap( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeLineCap( DrawingWand *drawing_wand, const LineCap linecap );

LineJoin MagickDrawGetStrokeLineJoin( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeLineJoin( DrawingWand *drawing_wand, const LineJoin linejoin );

unsigned long MagickDrawGetStrokeMiterLimit( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeMiterLimit( DrawingWand *drawing_wand, const unsigned long miterlimit );

double MagickDrawGetStrokeOpacity( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeOpacity( DrawingWand *drawing_wand, const double stroke_opacity );

double MagickDrawGetStrokeWidth( const DrawingWand *drawing_wand );

void MagickDrawSetStrokeWidth( DrawingWand *drawing_wand, const double stroke_width );

unsigned int MagickDrawGetTextAntialias( const DrawingWand *drawing_wand );

void MagickDrawSetTextAntialias( DrawingWand *drawing_wand, const unsigned int text_antialias );

DecorationType MagickDrawGetTextDecoration( DrawingWand *drawing_wand );

void MagickDrawSetTextDecoration( DrawingWand *drawing_wand, const DecorationType decoration );

char *MagickDrawGetTextEncoding( const DrawingWand *drawing_wand );

void MagickDrawSetTextEncoding( DrawingWand *drawing_wand, const char *encoding );

void MagickDrawGetTextUnderColor( const DrawingWand *drawing_wand, PixelWand *under_color );

void MagickDrawSetTextUnderColor( DrawingWand *drawing_wand, const PixelWand *under_wand );

void MagickDrawTranslate( DrawingWand *drawing_wand, const double x, const double y );

void MagickDrawSetViewbox( DrawingWand *drawing_wand, unsigned long x1, unsigned long y1,
                     unsigned long x2, unsigned long y2 );


//===================================================================================================
//===================================================================================================
//===================================================================================================
// Pixel Wand: http://www.graphicsmagick.org/wand/pixel_wand.html


PixelWand *NewPixelWand();

PixelWand **NewPixelWands( const unsigned long number_wands );

PixelWand *ClonePixelWand( const PixelWand *wand );

PixelWand **ClonePixelWands( const PixelWand *wands, const unsigned long number_wands );

unsigned int DestroyPixelWand( PixelWand *wand );

unsigned int PixelGetException( PixelWand *wand, char ** description );

double PixelGetBlack( const PixelWand *wand );

Quantum PixelGetBlackQuantum( const PixelWand *wand );

double PixelGetBlue( const PixelWand *wand );

Quantum PixelGetBlueQuantum( const PixelWand *wand );

char *PixelGetColorAsString( PixelWand *wand );

unsigned long PixelGetColorCount( const PixelWand *wand );

double PixelGetCyan( const PixelWand *wand );

Quantum PixelGetCyanQuantum( const PixelWand *wand );

double PixelGetGreen( const PixelWand *wand );

Quantum PixelGetGreenQuantum( const PixelWand *wand );

double PixelGetMagenta( const PixelWand *wand );

Quantum PixelGetMagentaQuantum( const PixelWand *wand );

double PixelGetOpacity( const PixelWand *wand );

Quantum PixelGetOpacityQuantum( const PixelWand *wand );

double PixelGetRed( const PixelWand *wand );

Quantum PixelGetRedQuantum( const PixelWand *wand );

double PixelGetYellow( const PixelWand *wand );

Quantum PixelGetYellowQuantum( const PixelWand *wand );

unsigned int PixelSetBlack( PixelWand *wand, const double black );

unsigned int PixelSetBlackQuantum( PixelWand *wand, const Quantum black );

unsigned int PixelSetBlue( PixelWand *wand, const double blue );

unsigned int PixelSetBlueQuantum( PixelWand *wand, const Quantum blue );

unsigned int PixelSetColor( PixelWand *wand, const char *color );

unsigned int PixelSetColorCount( PixelWand *wand, const unsigned long count );

unsigned int PixelSetCyan( PixelWand *wand, const double cyan );

unsigned int PixelSetCyanQuantum( PixelWand *wand, const Quantum cyan );

unsigned int PixelSetGreen( PixelWand *wand, const double green );

unsigned int PixelSetGreenQuantum( PixelWand *wand, const Quantum green );

unsigned int PixelSetMagenta( PixelWand *wand, const double magenta );

unsigned int PixelSetMagentaQuantum( PixelWand *wand, const Quantum magenta );

unsigned int PixelSetOpacity( PixelWand *wand, const double opacity );

unsigned int PixelSetOpacityQuantum( PixelWand *wand, const Quantum opacity );

void PixelSetQuantumColor( PixelWand *wand, PixelPacket *color );

unsigned int PixelSetRed( PixelWand *wand, const double red );

unsigned int PixelSetRedQuantum( PixelWand *wand, const Quantum red );

unsigned int PixelSetYellow( PixelWand *wand, const double yellow );

unsigned int PixelSetYellowQuantum( PixelWand *wand, const Quantum yellow );
]]

return ffi.load("GraphicsMagickWand")