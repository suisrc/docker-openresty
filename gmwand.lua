-- FFI bindings to GraphicsMagick:
local ffi = require "ffi"
ffi.cdef
[[
  // Magick types:
  typedef void MagickWand;
  typedef int MagickBooleanType;
  typedef int ExceptionType;
  typedef int size_t;
  typedef int ChannelType;
  typedef void PixelWand;
  typedef void DrawingWand;

  // Pixel formats:
  typedef enum
  {
    CharPixel,
    ShortPixel,
    IntPixel,
    LongPixel,
    FloatPixel,
    DoublePixel,
  } StorageType;

  // Noise types:
  typedef enum
  {
    UniformNoise,
    GaussianNoise,
    MultiplicativeGaussianNoise,
    ImpulseNoise,
    LaplacianNoise,
    PoissonNoise,
    RandomNoise,
    UndefinedNoise
  } NoiseType;

  // Resizing filters:
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

  // Channels:
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

  // Color spaces:
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

  // Image Type
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

  // InterlaceType
  typedef enum
  {
    UndefinedInterlace,
    NoInterlace,
    LineInterlace,
    PlaneInterlace,
    PartitionInterlace
  } InterlaceType;

  // AffineMatrix
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

  // =====================================================================================================
  // =====================================================================================================
  // =====================================================================================================

  // free
  void free(void *);
  unsigned int MagickRelinquishMemory( void *resource );

  // Global context:
  void MagickWandGenesis();
  void InitializeMagick();

  // Magick Wand:
  MagickWand* NewMagickWand();
  MagickWand* DestroyMagickWand(MagickWand*);
  MagickWand* CloneMagickWand( const MagickWand *wand );

  // Pixel Wand:
  PixelWand *NewPixelWand(void);
  PixelWand *DestroyPixelWand(PixelWand *wand);
  void PixelSetRed(PixelWand *wand,const double red);
  void PixelSetGreen(PixelWand *wand,const double green);
  void PixelSetBlue(PixelWand *wand,const double blue);

  // Drawing Wand:
  DrawingWand *MagickNewDrawingWand( void );
  void MagickDestroyDrawingWand( DrawingWand *drawing_wand );

  // Read/Write:
  MagickBooleanType MagickReadImage(MagickWand*, const char*);
  MagickBooleanType MagickReadImageBlob(MagickWand*, const void*, const size_t);
  MagickBooleanType MagickWriteImage(MagickWand*, const char*);
  unsigned char *MagickWriteImageBlob( MagickWand *wand, size_t *length );

  // Quality:
  unsigned int MagickSetCompressionQuality( MagickWand *wand, const unsigned long quality );

  //Exception handling:
  char* MagickGetException(const MagickWand*, ExceptionType*);

  // Dimensions:
  int MagickGetImageWidth(MagickWand*);
  int MagickGetImageHeight(MagickWand*);

  // Depth
  int MagickGetImageDepth(MagickWand*);
  unsigned int MagickSetImageDepth( MagickWand *wand, const unsigned long depth );

  // Resize:
  MagickBooleanType MagickResizeImage(MagickWand*, const size_t, const size_t, const FilterTypes, const double);

  // Set size:
  unsigned int MagickSetSize( MagickWand *wand, const unsigned long columns, const unsigned long rows );

  // Image format (JPEG, PNG, ...)
  char* MagickGetImageFormat(MagickWand* wand);
  MagickBooleanType MagickSetImageFormat(MagickWand* wand, const char* format);

  // Image interlace
  unsigned int MagickSetInterlaceScheme( MagickWand *wand, const InterlaceType interlace_scheme );

  // Raw data:
  unsigned int MagickGetImagePixels( MagickWand *wand, const long x_offset, const long y_offset, const unsigned long columns, const unsigned long rows,
                                     const char *map, const StorageType storage, unsigned char *pixels );
  unsigned int MagickSetImagePixels( MagickWand *wand, const long x_offset, const long y_offset, const unsigned long columns, const unsigned long rows,
                                     const char *map, const StorageType storage, unsigned char *pixels );

  // Flip/Flop
  unsigned int MagickFlipImage( MagickWand *wand );
  unsigned int MagickFlopImage( MagickWand *wand );

  // Rotate
  unsigned int MagickRotateImage( MagickWand *wand, const PixelWand *background, const double degrees );

  // Crop
  unsigned int MagickCropImage( MagickWand *wand, const unsigned long width, const unsigned long height, const long x, const long y );
  unsigned int MagickBorderImage( MagickWand *wand, const PixelWand *bordercolor, const unsigned long width, const unsigned long height );

  // Processing
  unsigned int MagickColorFloodfillImage( MagickWand *wand, const PixelWand *fill, const double fuzz, const PixelWand *bordercolor, const long x, const long y );
  unsigned int MagickNegateImage( MagickWand *wand, const unsigned int gray );
  unsigned int MagickSetImageBackgroundColor( MagickWand *wand, const PixelWand *background );
  MagickWand *MagickFlattenImages( MagickWand *wand );
  unsigned int MagickBlurImage( MagickWand *wand, const double radius, const double sigma );
  unsigned int MagickAddNoiseImage( MagickWand *wand, const NoiseType noise_type );
  unsigned int MagickColorizeImage( MagickWand *wand, const PixelWand *colorize, const PixelWand *opacity );

  // Composing
  unsigned int MagickCompositeImage( MagickWand *wand, const MagickWand *composite_wand, const CompositeOperator compose, const long x, const long y );

  // Colorspace:
  ColorspaceType MagickGetImageColorspace( MagickWand *wand );
  unsigned int MagickSetImageColorspace( MagickWand *wand, const ColorspaceType colorspace );

  // Description
  char *MagickDescribeImage( MagickWand *wand );

  // SamplingFactors
  double *MagickGetSamplingFactors(MagickWand *,unsigned long *);
  unsigned int MagickSetSamplingFactors(MagickWand *,const unsigned long,const double *);

  // ImageType
  unsigned int MagickSetImageType( MagickWand *, const ImageType );
  ImageType MagickGetImageType( MagickWand *);

  // DrawAffine
  void MagickDrawAffine( DrawingWand *drawing_wand, const AffineMatrix *affine );
  unsigned int MagickAffineTransformImage( MagickWand *wand, const DrawingWand *drawing_wand );

  // ImageGamma
  double MagickGetImageGamma(MagickWand *wand);
  unsigned int MagickSetImageGamma(MagickWand *wand, const double gamma);
  unsigned int MagickGammaImage(MagickWand *wand, const double gamma);
  unsigned int MagickGammaImageChannel(MagickWand *wand, const ChannelType channel_type, const double gamma);
  unsigned int MagickSharpenImage(MagickWand *wand, const double radius, const double sigma); 
  unsigned int MagickUnsharpMaskImage(MagickWand* wand, const double radius, const double sigma, const double amount, const double threshold);

  // Profile
  unsigned char* MagickGetImageProfile(MagickWand *wand,const char *name,unsigned long *length);
  unsigned int MagickProfileImage(MagickWand* wand, const char* name, const void* profile, const size_t length);
]]

local clib = ffi.load("GraphicsMagickWand")

-- Wrapper around `MagickGetException` to report errors:
local function magick_error(self, ctx)
    ctx = ctx or 'error'
    local etype = ffi.new('int[1]')
    local descr = ffi.gc(clib.MagickGetException(self.wand, etype),clib.MagickRelinquishMemory)
    error(string.format(
       '%s: %s: %s (ExceptionType=%d)',
       self.name, ctx, ffi.string(descr), etype[0]
    ))
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Image object:
local Image = {
    name = 'magick.Image',
    path = '<>',
    buffers = {
       HWD = {},
       DHW = {},
    }
}
-- Metatable:
setmetatable(Image, {
    __call = function(self,...)
       return self.new(...)
    end
})
-- Constructor:
function Image.new(pathOrTensor, ...)
    -- Create new instance:
    local image = {}
    for k,v in pairs(Image) do
       image[k] = v
    end
    -- Create Wand:
    image.wand = ffi.gc(clib.NewMagickWand(), clib.DestroyMagickWand)
    -- Arg?
    if type(pathOrTensor) == 'string' then
       -- Is a path:
       image:load(pathOrTensor, ...)
    elseif type(pathOrTensor) == 'userdata' then
       -- Is a tensor:
       image:fromTensor(pathOrTensor, ...)
    end
    --
    return image
end
-- Load image:
function Image:load(path, width, height)
    -- Set canvas size:
    if width then
       -- This gives a cue to the wand that we don't need
       -- a large image than this. This is super cool, because
       -- it speeds up the loading of large images by a lot.
       clib.MagickSetSize(self.wand, width, height or width)
    end
    -- Load image:
    local status = clib.MagickReadImage(self.wand, path)
    -- Error?
    if status == 0 then
       magick_error(self, 'error loading image')
    end
    -- Save path:
    self.path = path
    -- return self
    return self
end
-- Save image:
function Image:save(path, quality)
   -- Format?
   -- local format = (path:gfind('%.(...)$')() or path:gfind('%.(....)$')()):upper()
   -- if format == 'JPG' then format = 'JPEG' end
   -- self:format(format)
   -- Set quality:
   quality = quality or 85
   clib.MagickSetCompressionQuality(self.wand, quality)
   -- Save:
   local status = clib.MagickWriteImage(self.wand, path)
   -- Error?
   if status == 0 then
      magick_error(self, 'error saving image')
   end
   -- return self
   return self
end
-- Export to Blob:
function Image:toBlob(quality)
     -- Size pointer:
     local sizep = ffi.new('size_t[1]')
     -- Set quality:
     if quality then
        clib.MagickSetCompressionQuality(self.wand, quality)
     end
     -- To Blob:
     local blob = ffi.gc(clib.MagickWriteImageBlob(self.wand, sizep), ffi.C.free)
     -- Return blob and size:
     return blob, tonumber(sizep[0])
end
-- Export to string:
function Image:toString(quality)
     -- To blob:
     local blob, size = self:toBlob(quality)
     -- Lua string:
     local str = ffi.string(blob,size)
     -- Return string:
     return str
end
-- Description:
function Image:info()
    -- Get information
    local str = ffi.gc(clib.MagickDescribeImage(self.wand), ffi.C.free)
    return ffi.string(str)
end

------------------------------------------------------------------------------------------------------------------------
-- Clone image:
function Image:clone()
    local out = Image()
    for k,v in pairs(Image) do
       out[k] = self[k]
    end
    for k,v in pairs(out.buffers) do
       v = nil
    end
    out.wand = ffi.gc(clib.CloneMagickWand(self.wand), clib.DestroyMagickWand)
    --
    return out
end 
-- To Tensor:
function Image:toTensor(dataType, colorspace, dims, nocopy)
   require "torch"
   -- Dims:
   local width,height = self:size()

   -- Color space:
   colorspace = colorspace or 'RGB'  -- any combination of R, G, B, A, C, Y, M, K, and I
   -- common colorspaces are: RGB, RGBA, CYMK, and I
   -- Other colorspaces?
   if colorspace == 'HSL' or colorspace == 'HWB' or colorspace == 'LAB' or colorspace == 'YUV' then
      -- Switch to colorspace:
      self:colorspace(colorspace)
      colorspace = 'RGB'
   end
   -- Type:
   dataType = dataType or 'byte'
   local tensorType, pixelType
   if dataType == 'byte' then
      tensorType = 'ByteTensor'
      pixelType = 'CharPixel'
   elseif dataType == 'float' then
      tensorType = 'FloatTensor'
      pixelType = 'FloatPixel'
   elseif dataType == 'double' then
      tensorType = 'DoubleTensor'
      pixelType = 'DoublePixel'
   else
      error(Image.name .. ': unknown data type ' .. dataType)
   end
   -- Dest:
   local tensor = Image.buffers['HWD'][tensorType] or torch[tensorType]()
   tensor:resize(height,width,#colorspace)
   -- Cache tensor:
   Image.buffers['HWD'][tensorType] = tensor
   -- Raw pointer:
   local ptx = torch.data(tensor)
   -- Export:
   clib.MagickGetImagePixels(self.wand,
                             0, 0, width, height,
                             colorspace, clib[pixelType],
                             ffi.cast('unsigned char *',ptx))
   -- Dims:
   if dims == 'DHW' then
      -- Transposed Tensor:
      local tensorDHW = Image.buffers['DHW'][tensorType] or tensor.new()
      tensorDHW:resize(#colorspace,height,width)
      -- Copy:
      tensorDHW:copy(tensor:transpose(1,3):transpose(2,3))
      -- Cache:
      Image.buffers['DHW'][tensorType] = tensorDHW
      -- Return:
      tensor = tensorDHW
   end
   -- Return tensor
   if nocopy then
      return tensor
   else
      return tensor:clone()
   end
end
-- Import from blob:
function Image:fromBlob(blob,size)
   -- Read from blob:
   local status = clib.MagickReadImageBlob(
    self.wand, ffi.cast('const void *', blob), size
   )
   if status == 0 then
      magick_error(self, 'error reading from blob')
   end
   -- Save path:
   self.path = '<blob>'
   -- return self
   return self
end
-- Import from blob:
function Image:fromString(string)
   -- Convert blob (lua string) to C string
   local size = #string
   blob = ffi.new('char['..size..']', string)

   -- Load blob:
   return self:fromBlob(blob, size)
end
-- From Tensor:
function Image:fromTensor(tensor, colorspace, dims)
   require 'torch'
   -- Dims:
   local height,width,depth
   if dims == 'DHW' then
      depth,height,width= tensor:size(1),tensor:size(2),tensor:size(3)
      tensor = tensor:transpose(1,3):transpose(1,2)
   else -- dims == 'HWD'
      height,width,depth = tensor:size(1),tensor:size(2),tensor:size(3)
   end
   -- Force contiguous:
   tensor = tensor:contiguous()
   -- Color space:
   if not colorspace then
      if depth == 1 then
         colorspace = 'I'
      elseif depth == 3 then
         colorspace = 'RGB'
      elseif depth == 4 then
         colorspace = 'RGBA'
      else
      end
   end
   -- any combination of R, G, B, A, C, Y, M, K, and I
   -- common colorspaces are: RGB, RGBA, CYMK, and I
   -- Compat:
   assert(#colorspace == depth, Image.name .. '.fromTensor: Tensor depth must match color space')
   -- Type:
   local ttype = torch.typename(tensor)
   local pixelType
   if ttype == 'torch.FloatTensor' then
      pixelType = 'FloatPixel'
   elseif ttype == 'torch.DoubleTensor' then
      pixelType = 'DoublePixel'
   elseif ttype == 'torch.ByteTensor' then
      pixelType = 'CharPixel'
   else
      error(Image.name .. ': only dealing with float, double and byte')
   end
   -- Raw pointer:
   local ptx = torch.data(tensor)
   -- Resize image:
   self:load('xc:black')
   self:size(width,height)
   if colorspace == "RGBA" then
      clib.MagickSetImageType(self.wand, clib.TrueColorMatteType)
   end
   -- Export:
   clib.MagickSetImagePixels(self.wand,
                             0, 0, width, height,
                             colorspace, clib[pixelType],
                             ffi.cast("unsigned char *", ptx))
   -- Save path:
   self.path = '<tensor>'
   -- return self
   return self
end

------------------------------------------------------------------------------------------------------------------------
return {
    lib = clib,
    err = magick_error,
    Image = Image
}