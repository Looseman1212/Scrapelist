import { Controller } from "@hotwired/stimulus"

let GROUPCOUNT = 0;
let WINDOWCOUNT = 0;

// Connects to data-controller="picky-genre-menu"
export default class extends Controller {
  static targets = ["nextbtn", "windowone", "windowtwo", "whindowthree", "backbtnwindowtwo", "nextbtnwindowtwo"]

  connect() {
    console.log('hello');
    // reset the iterators to 0 whenever the controller is connected
    GROUPCOUNT = 0;
    WINDOWCOUNT = 0;
    // this.whenBtnsIfAllSubgenres();
  }

  scrollUp() {
    console.log('up');
    // define the buttons
    const upButton = document.querySelector('.up-picky-menu-action');
    const downButton = document.querySelector('.down-picky-menu-action');
    const genreGroup = document.querySelectorAll('.picky-genre-menu-group');
    // hide the current group
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group-picky');
    // show the previous group if there is one
    if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].removeAttribute('id', 'inactive-list-group-picky');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    GROUPCOUNT -= 1;
    // hide the up button if user is at the top of the menu
    if (GROUPCOUNT == 0) {
      upButton.setAttribute('id', 'inactive-button');
    } else {
      upButton.removeAttribute('id', 'inactive-button');
      downButton.removeAttribute('id', 'inactive-button');
    }
  }

  scrollDown() {
    console.log('down');
    // define the buttons
    const upButton = document.querySelector('.up-picky-menu-action');
    const downButton = document.querySelector('.down-picky-menu-action');
    const genreGroup = document.querySelectorAll('.picky-genre-menu-group');
    // hide the current group
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group-picky');
    // show the next group if there is one
    if (genreGroup[GROUPCOUNT + 1] != null) {
      genreGroup[GROUPCOUNT + 1].removeAttribute('id', 'inactive-list-group-picky');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    GROUPCOUNT += 1;
    // hide the down button if user is at the bottom of the menu
    upButton.removeAttribute('id', 'inactive-button');
    if (GROUPCOUNT == 2) {
      downButton.setAttribute('id', 'inactive-button');
    } else {
      downButton.removeAttribute('id', 'inactive-button');
      upButton.removeAttribute('id', 'inactive-button');
    }
  }

  selectSurprise() {
    // define the radio buttons and the surprise button
    const radioButtons = document.getElementsByName('scrapelistprompt[genre]');
    const surpriseButton = document.getElementById('scrapelistprompt_genre_surprise');
    // create a random number between 0 and the number of radio buttons (not including the surprise button)
    const rand = Math.floor(Math.random() * (radioButtons.length - 1));
    if (rand == 0) {
      // if the random number is 0 (which would be the ALL button), set the surprise button value to acoustic
      surpriseButton.value = "acoustic"
      console.log(surpriseButton);
    } else {
      // otherwise, set the surprise button value to the value of a random radio button
      const randomValue = radioButtons[rand].value;
      surpriseButton.value = randomValue;
      console.log(surpriseButton);
    }
  }

  nextWindow(event) {
    // stop the form from being submitted too early
    event.preventDefault();
    console.log('next button clicked');
    // define the windows
    const windows = document.querySelectorAll('.form-window');
    // hide the current window
    windows[WINDOWCOUNT].setAttribute('id', 'display-none-picky');
    // show the next window if there is one
    if (windows[WINDOWCOUNT + 1] != null) {
      windows[WINDOWCOUNT + 1].removeAttribute('id', 'display-none-picky');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    WINDOWCOUNT += 1;
    if (WINDOWCOUNT == 1) {
      this.whenBtnsIfAllSubgenres();
    }
    // relocate the scroll to the top of the page
    window.scrollTo(0, 0);
  }

  previousWindow(event) {
    // stop the form from being submitted too early
    event.preventDefault();
    console.log('back button clicked');
    // define the windows
    const windows = document.querySelectorAll('.form-window');
    // hide the current window
    windows[WINDOWCOUNT].setAttribute('id', 'display-none-picky');
    // show the previous window if there is one
    if (windows[WINDOWCOUNT - 1] != null) {
      windows[WINDOWCOUNT - 1].removeAttribute('id', 'display-none-picky');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    WINDOWCOUNT -= 1;
    // relocate the scroll to the top of the page
    window.scrollTo(0, 0);
  }

  genreThenShowSubgenres() {
    const genre_buttons = document.querySelectorAll('input[name="scrapelistprompt[genre]"]');
    const subgenre_container = document.querySelector('.subgenre-container');
    const subgenre_buttons = document.querySelectorAll('.subgenre-buttons');
    const release_type_container = document.querySelector('.release-type-container');
    const when_buttons_container = document.querySelector('.when-buttons-container');
    const when_container = document.querySelector('.when-container');
    // hide all the subgenre buttons everytime this function is called
    subgenre_buttons.forEach((button) => {
      button.setAttribute('id', 'display-none-picky');
    });
    // select which subgenre buttons to show based on which genre button is checked
    genre_buttons.forEach((button) => {
      if (button.checked && button.value == 'all') {
        subgenre_container.setAttribute('id', 'display-none-picky');
        release_type_container.removeAttribute('id', 'visibility-hidden-picky');
        when_container.removeAttribute('id', 'visibility-hidden-picky');
        when_buttons_container.removeAttribute('id', 'visibility-hidden-picky');
        console.log('all genres selected');
      } else if (button.checked) {
        subgenre_container.removeAttribute('id', 'display-none-picky');
        const subgenre_toshow = document.querySelector(`.${button.value}-subgenres`);
        subgenre_toshow.removeAttribute('id', 'display-none-picky');
        console.log(`${button.value} selected`);
      }
    });
  }

  whenBtnsIfAllSubgenres() {
    // define variables
    const subgenre_buttons = document.querySelectorAll('input[name="scrapelistprompt[subgenre]"]');
    const release_type_container = document.querySelector('.release-type-container');
    const when_container = document.querySelector('.when-container');
    const when_buttons_container = document.querySelector('.when-buttons-container');
    const next_btn_windowtwo = document.querySelector('#next-btn-windowtwo');
    // reset the release_type and when containers to hidden
    release_type_container.setAttribute('id', 'visibility-hidden-picky');
    when_container.setAttribute('id', 'visibility-hidden-picky');
    next_btn_windowtwo.setAttribute('id', 'visibility-hidden-picky');
    // set a click event for if the user clicks any of the subgenre_buttons
    subgenre_buttons.forEach((button) => {
      button.addEventListener('click', (event) => {
        // unhide the release_type and when containers when a subgenre button is clicked
        release_type_container.removeAttribute('id', 'visibility-hidden-picky');
        when_container.removeAttribute('id', 'visibility-hidden-picky');
        next_btn_windowtwo.removeAttribute('id', 'visibility-hidden-picky');
        // if the user clicks the ALL button, show the when_buttons_container
        if (button.value.endsWith("~all")) {
          when_buttons_container.removeAttribute('id', 'visibility-hidden-picky');
        } else {
          // if the user clicks any other button, hide the when_buttons_container
          when_buttons_container.setAttribute('id', 'visibility-hidden-picky');
          // and set the this_week button to checked
          const this_week_btn = document.getElementById('scrapelistprompt_time_frame_0')
          this_week_btn.checked = true;
        }
      });
    });
  }
}
