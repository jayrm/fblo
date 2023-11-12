'' try to include all headers and check for conflicts

#include "FBImage.bi"

#include "zlib.bi"

#include "png16.bi"

#include "fbpng/fbpng.bi"
#include "fbpng/fbmld.bi"
#include "fbpng/fbpng_gfxlib2.bi"
#include "fbpng/fbpng_opengl.bi"
'' #include "fbpng/png_image.bi"
'' #include "fbpng/png_row_conv.bi"
'' #include "fbpng/png_pal_conv.bi"

#include "dumb/dumb.bi"

#include "mad/mad.bi"

#include "ogg/ogg.bi"

#include "vorbis/codec.bi"
#include "vorbis/vorbisenc.bi"
#include "vorbis/vorbisfile.bi"

#include "csid/libcsidlight.bi"

'' dynamic or static only

'' #include "fbsound/fbsound_dynamic.bi"
#include "fbsound/fbsound.bi"

#include "fbsound/fbs-config.bi"
#include "fbsound/fbstypes.bi"
#include "fbsound/fbscpu.bi"
#include "fbsound/fbsdsp.bi"
#include "fbsound/fbs3d.bi"
#include "fbsound/fbsound_oop.bi"

#define PCRE_CODE_UNIT_WIDTH 8
#include once "pcre.bi"
