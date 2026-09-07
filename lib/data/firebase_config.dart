/// Firebase Realtime Database used by the local agent to publish Digital Twins.
const firebaseRtdbUrl = 'https://twinmatch-659d6-default-rtdb.firebaseio.com';
const twinsPath = 'twins';

String twinsCollectionUrl() => '$firebaseRtdbUrl/$twinsPath.json';

String twinUrl(String machineId) =>
    '$firebaseRtdbUrl/$twinsPath/${Uri.encodeComponent(machineId)}.json';
