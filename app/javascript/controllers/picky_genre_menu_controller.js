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
  }

  scrollUp() {
    console.log('up');
    // define the buttons
    const upButton = document.querySelector('.up-picky-menu-action');
    const downButton = document.querySelector('.down-picky-menu-action');
    const genreGroup = document.querySelectorAll('.picky-genre-menu-group');
    // hide the current group
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    // show the previous group if there is one
    if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].removeAttribute('id', 'inactive-list-group');
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
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    // show the next group if there is one
    if (genreGroup[GROUPCOUNT + 1] != null) {
      genreGroup[GROUPCOUNT + 1].removeAttribute('id', 'inactive-list-group');
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
    windows[WINDOWCOUNT].setAttribute('id', 'display-none');
    // show the next window if there is one
    if (windows[WINDOWCOUNT + 1] != null) {
      windows[WINDOWCOUNT + 1].removeAttribute('id', 'display-none');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    WINDOWCOUNT += 1;
  }

  previousWindow(event) {
    // stop the form from being submitted too early
    event.preventDefault();
    console.log('back button clicked');
    // define the windows
    const windows = document.querySelectorAll('.form-window');
    // hide the current window
    windows[WINDOWCOUNT].setAttribute('id', 'display-none');
    // show the previous window if there is one
    if (windows[WINDOWCOUNT - 1] != null) {
      windows[WINDOWCOUNT - 1].removeAttribute('id', 'display-none');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    WINDOWCOUNT -= 1;
  }

  genreThenShowSubgenres() {
    const genre_buttons = document.querySelectorAll('input[name="scrapelistprompt[genre]"]');
    const subgenre_buttons = document.querySelectorAll('.subgenre-buttons');
    // hide all the subgenre buttons everytime this function is called
    subgenre_buttons.forEach((button) => {
      button.setAttribute('id', 'display-none');
    });
    // select which subgenre buttons to show based on which genre button is checked
    genre_buttons.forEach((button) => {
      if (button.checked) {
        const subgenre_toshow = document.querySelector(`.${button.value}-subgenres`);
        // console.log(subgenre_toshow);
        subgenre_toshow.removeAttribute('id', 'display-none');
      }
    });
  }
}
