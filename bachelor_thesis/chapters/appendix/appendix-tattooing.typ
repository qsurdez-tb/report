= Tattooing : implementation details <appendix-tattooing>

Source listings for the tattooing chapter (@tattooing), all from `views/images/__init__.py`.

== Entry point

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
  caption: [The tattooing entry point (ln 404-417). It applies the two layers in turn and restores the original DPI metadata afterwards.]
)

== Layer 1, the visible identifier barcode

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
  caption: [`tag_visible` (ln 369-401). Renders a CODE128 barcode of the file identifier with human-readable text and pastes it at the top, shifting the image content down.]
)

== Layer 2, the near-invisible tracking strip

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
  caption: [`tag_bottom` (ln 333-367). With `module_height` 1.0, `quiet_zone` 0 and `write_text` disabled, the barcode is a roughly 10-pixel strip with no readable characters, appended at the bottom-right.]
)
