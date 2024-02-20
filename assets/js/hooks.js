const TOGGLE_BTN = () => {
  const target_el = document.querySelector("#delete-all-btn");
  const REQ_ELEMS = document.querySelectorAll("#requests li");

  if (REQ_ELEMS.length > 0) {
    target_el.classList.remove("opacity-0");
    target_el.classList.add("opacity-100");
  } else {
    target_el.classList.remove("opacity-100");
    target_el.classList.add("opacity-0");
  }
};

const Hooks = {
  ToogleDeleteAllButton: {
    mounted() {
      TOGGLE_BTN()
    },
    updated() {
      TOGGLE_BTN()
    }
  },
  HighlightCode: {
    // mounted() {
    //   hljs.highlightElement(this.el)
    // },
    // updated() {
    //   hljs.highlightElement(this.el)
    // }
  }
};

export default Hooks;
