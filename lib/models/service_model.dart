//service item 
class Service {
  final String name;          
  final String description;  
  final String imagepath;   
  final double price;      
  final serviceCategory category; 

Service({
  required  this.name,
  required  this.description,
  required  this.imagepath,
  required  this.price,
  required  this.category,
});
}
 
//service categories 
enum serviceCategory{
  plumbing,
  painting,
  electrical,
  home_finishing,
  cleaning,
  babysitter,
  carpentry,

}

