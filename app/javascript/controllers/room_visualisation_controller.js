import { Controller } from '@hotwired/stimulus'
import RoomVisualisation from 'components/room_visualisation';

export default class extends Controller {
  connect() {
    RoomVisualisation.update();
  }

  update() {
    RoomVisualisation.update();
  }
}
