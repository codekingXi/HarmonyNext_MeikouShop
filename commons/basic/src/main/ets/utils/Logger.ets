import { Log } from '@abner/log'

Log.init({
  tag: 'MK_LOGGER',
  domain: 0x0101,
  close: false,
  isHilog: true,
  showLogLocation: true,
  logSize: 1024
})

export { Log as Logger }