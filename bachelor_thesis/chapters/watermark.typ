#import "../macros.typ": note

= Watermark process

ICNML implements an image watermarking mechanism that adds 
a CODE128 barcode into every image downloaded. The mechanism is called tattooing in the source code (`image_tattoo` in `views/images/__init__.py`).
Its purpose is to tie every downloaded copy of an image to the user who downloaded it and the moment of the download. 

== Overview

The tattooing is applied in two steps calling two separate
helper functions:

#figure(
  ```python
  def image_tatoo( img, image_id ):
    image_id = image_id[ 0:18 ]
    res = img.info.get( "dpi", ( 72, 72 ) )

    img = tag_visible( img, image_id )
    img = tag_bottom( img, "{} {}".format( session[ "user_id" ], time.time() ) )

    img.info[ "dpi" ] = res
    return img
  ```,
  caption: [Image tattooing entry point (`views/images/__init__.py`, ln 404-417)]
)

The DPI metadata of the original image is kept across the different following operations.

== Layers

=== Layer 1, Visible Identifier Barcode

The function `tag_visible` generates a CODE128 barcode encoding the first 18 characters of the file UUID and pastes it at the top of the image. The original image content is shifted downward.


#figure(
  ```python
  options = {
        'module_width': 0.2,
        'module_height': 4,
        'quiet_zone': 2,
        'font_size': 10,
        'text_distance': 1,
    }
  barcode.generate( 'code128', data, writer = barcode.writer.ImageWriter(), output = fp, writer_options = options )
  codebar_img = Image.open( fp )
  
  size = list( img.size )
  size[ 1 ] += codebar_img.size[ 1 ]

  if img.mode == "L":
      bg = 255
      mode = "L"
  else:
      bg = ( 255, 255, 255 )
      mode = "RGB"

  ret = Image.new( mode, size, bg )
  ret.paste( img, ( 0, codebar_img.size[ 1 ] ) )
  ret.paste( codebar_img, ( size[ 0 ] - codebar_img.size[ 0 ], 0 ) )

  return ret
  ```,
  caption: [Visible barcode generation (`views/images/__init__.py`, ln 369-401)]
)

The barcode is rendered with text below the bars. It is visible to the naked eye and scannable with any standard barcode reader. It encodes only part of the file identifier.
There's no user or session information or timestamp.

=== Layer 2, Almost Invisible Tracking Barcode

The function `tag_bottom` generates a second CODE128 barcode encoding the downloader's `user_id` and the Unix timestamp of the download. It is appended as a 10-pixel high strip at the bottom-right corner of the image.

#figure(
  ```python
  top = 10
  h = 10
  options = {
        'module_width': 0.2,
        'module_height': 1.0,
        'quiet_zone': 0,
        'write_text': False,
  }
  barcode.generate( 'code128', data, writer = barcode.writer.ImageWriter(), output = fp, writer_options = options )
  codebar_img = Image.open( fp )
  codebar_img = codebar_img.crop( ( 0, top, codebar_img.width, top + h ) )
  
  size = list( img.size )
  size[ 1 ] += h

  if img.mode == "RGB":
      bg = ( 255, 255, 255 )
  else:
      bg = 255

  ret = Image.new( img.mode, size, bg )
  ret.paste( img, ( 0, 0 ) )
  ret.paste( codebar_img, ( size[ 0 ] - codebar_img.size[ 0 ], size[ 1 ] - codebar_img.size[ 1 ] ) )

  return ret
  ```,
  caption: [Near-invisible tracking barcode generation (`views/images/__init__.py`, ln 333-367)]
)

With `module_height: 1.0`, `quiet_zone: 0`, and `write_text: False`, the created barcode is approximately 10 pixels tall and contains no readable characters. It is difficult to see without magnification or image analysis. 

The payload `"{user_id} {unix_timestamp}` provides a direct audit trail linking the copy to an authenticated user and a specific time.

#note[This mechanism doesn't withstand cropping or transformations on an image]

== Where the Watermark is Applied

The `image_tatoo` function is called in locations where the user can download the image (`GET /submission/<submission_uuid>/targets/download`, `GET /afis/<uuid>/download`, `GET /afis/<uuid>/download_exercise`, etc...).

However, there are also many paths serving images that do not apply any watermark: 

- `GET /image/file/<file_id>/preview`, JPEG preview served to logged-in users.
- `GET /image/file/<file_id>/tiff`, full TIFF served to logged-in users.

This means that the preview images can be downloaded without any watermarking and thus no audit trails.

#figure(
  image("../assets/watermark-flow.drawio.png"),
  caption: [Watermark flow from a download endpoint]
)