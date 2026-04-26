var resize_to_height = true;

// Clears any previous rotations
function rotate_reset() {
  // Remove custom CSS from inner wrappers, but don't remove wrappers
  if (selector_exists('#wrap_rotate')) {
    $('#wrap_rotate').attr('style', '');
    $('#wrap_rotate_inner').attr('style', '');
  }
}

function selector_exists(selector) {
  return ($(selector).length > 0);
}

// Rotates the document
function rotate(angle) {
  // Reset before changing the angle
  rotate_reset();

  // If the angle is set to 0, we only needed to reset the rotate. Done!
  if (angle === "0") {
    return true;
  }

  // Create the wrappers
  var wrap_rotate;
  var wrap_rotate_inner;

  if (!selector_exists("#wrap_rotate")) {
    // Create the elements
    wrap_rotate = $('<div />', {
      id: "wrap_rotate"
    });
    wrap_rotate_inner = $('<div />', {
      id: "wrap_rotate_inner"
    });;

    // Append to the body
    $('body').wrapInner(wrap_rotate_inner).wrapInner(wrap_rotate);
  }

  // Fetch the existing elements
  var wrap_rotate = $('#wrap_rotate');
  var wrap_rotate_inner = $('#wrap_rotate_inner');

  var body_width = $('body').height();
  var body_height = $('body').width();
  var window_width = $(window).height();
  wrap_rotate.attr('style', "overflow-y: hidden; height: " + window_width + "px;");

  // Handle the angle
  switch (angle.toString()) {
    case "270":
      body_height -= 200; // for the scrollbar

      // Apply the appropriate style
      wrap_rotate_inner.attr('style', "position: relative; left: -100%; -webkit-transform: rotateZ(-90deg); -webkit-transform-origin-x: 100%; -webkit-transform-origin-y: 0%; float: right; " + (resize_to_height ? "width: " + window_width + "px;" : ""));

      return;
    case "90":
      body_width += 200;

      // Apply the appropriate style
      wrap_rotate.attr('style', "overflow-y: hidden; height: " + window_width + "px;");
      wrap_rotate_inner.attr('style', "position: relative; left: 100%; -webkit-transform: rotateZ(90deg); -webkit-transform-origin-x: 0%; -webkit-transform-origin-y: 0%; float: right; " + (resize_to_height ? "width: " + window_width + "px;" : ""));

      wrap_rotate.css('width', body_width + 'px');
      return;
    default:
      // Uh oh
      console.log('Invalid angle');
      return;
  }
}

$(document).ready(function(e) {
  // Perform the rotation
  if (window.rotateDegrees != null) {
    console.log("Rotate " + window.rotateDegrees);
    rotate(window.rotateDegrees);
  }
});
