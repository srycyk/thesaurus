
$(function() {
  // Show/hide words according to their type, eg noun verb
  $('.word-label-radio').each(
    function() {
      $(this).bind('click', function() {
        var wordType = $(this).attr('value'),
            rate = 'fast';

        if (wordType === 'all') {
          $('.word-link:hidden').each(function() { $(this).fadeIn(rate) })
        }
        else {
          $('.word-link:visible').each(function() { $(this).fadeOut(rate) })

          $('.word-link.' + wordType).each(function() { $(this).fadeIn(rate) })
        }
      })
    }
  );

  function replaceSelectedList(data) {
    $('#selected-list').replaceWith(data)
    return false
  }

  // Remove all chosen words
  $('#clear-selected').live('ajax:success', function(event, data, status, xhr) { return replaceSelectedList(data) });

  // Sort chosen words
  $('#sort-selected').live('ajax:success', function(event, data, status, xhr) { return replaceSelectedList(data) });

  // Remove a single chosen word
  $('.remove-selected').live('ajax:success', function(event, data, status, xhr) { return replaceSelectedList(data) });

  // Remove all the lists of associated words
  $('#clear-linked').bind('click', function() { $('#linked-words-panel').empty(); return false });

  // Place cursor on lookup field
  $('#word-input').focus();

  // Remove splash partial on user activity
  $('body').one('mousedown keypress', function() { $('#splash').remove(); })
});
