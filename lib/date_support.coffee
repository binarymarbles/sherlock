# Miscellanious date support code.
class DateSupport

  @stripSeconds: (date) ->
    date.setSeconds 0
    date.setMilliseconds 0
    date

module.exports = DateSupport
