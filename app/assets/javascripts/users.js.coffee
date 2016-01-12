
$ ->
  $('input[type=checkbox][name="user[send_standup_report]"]').on 'change', ->
    $(this).parents('form').submit()

