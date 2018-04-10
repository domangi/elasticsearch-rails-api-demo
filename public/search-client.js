const movies_search_url = "/api/v1/movies?search=";
const vm = new Vue({
  el: '#app',
  data: {
    query: "",
    results: [],
    page: 1,
  },
  methods: {
    search: function(){
      let url = movies_search_url + "" + this.query+"&page="+this.page;
      axios.get(url)
      .then(response => {this.results = response.data.movies})
    },
    nextpage: function(){
      this.page += 1;
      this.search();
    }
  }
});
