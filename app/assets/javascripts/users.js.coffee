
$ ->
  $('input[type=checkbox][name="user[send_standup_report]"]').on 'change', ->
    $(this).parents('form').submit()

  $('input[type=checkbox][name="user[disabled]"]').on 'change', ->
    $(this).parents('form').submit()

