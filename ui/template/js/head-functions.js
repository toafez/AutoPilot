setInterval("div_refresh();",5000); 
    function div_refresh(){
      $('#refresh').load(location.href + ' #area');
    }

