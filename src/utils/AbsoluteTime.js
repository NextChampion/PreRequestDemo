import {NativeModules} from 'react-native';
const KSAbsoluteTimeManager = NativeModules.KSAbsoluteTimeManager;

class KSAbsoluteTime {
  logCurrentTime(desc) {
    KSAbsoluteTimeManager.logCurrentTimeWithDesc(desc);
  }
}
export default new KSAbsoluteTime();
