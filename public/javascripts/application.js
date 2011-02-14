// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function validateform(){
  if (!isNaN(document.getElementById( "cost" ).value))
    {
      document.getElementById( "costerr" ).className='off';
      return true;
    }
  else
    {
      document.getElementById( "costerr" ).className='on'
      return false;
    }
}