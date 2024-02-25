export default class RoomVisualisation {
  static setup() {
  }

  static update() {
    // struct to temp save used rooms
    let roomNumers = {
      double_room: 0.0,
      single_room: 0,
      no_accommodation: 0
    }
    // check seleced value for all persons
    let accomondationSelectElements = document.querySelectorAll('.nested-fields:not([style*="display: none"]) .registration_registration_entries_accommodation select[name$="][accommodation]"]');
    accomondationSelectElements.forEach(function(element) {
      roomNumers[element.value]++;
    });
    // devide double rooms by 2 (double room is for two persons)
    roomNumers['double_room'] /= 2;
    // display values in frontend
    document.getElementById('number-double-room').innerText = roomNumers['double_room'];
    document.getElementById('number-single-room').innerText = roomNumers['single_room'];
    document.getElementById('number-no-room').innerText = roomNumers['no_accommodation'];
    // highlight invalid amount of double rooms
    if(roomNumers['double_room'] % 1 == 0) {
      document.getElementById('number-double-room').classList.remove('text-danger');
    } else {
      document.getElementById('number-double-room').classList.add('text-danger');
    }
  }
};
