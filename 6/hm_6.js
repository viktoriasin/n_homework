//подсчитайте число элементов в созданной коллекции tags в bd movies

db.tags.count()
db.tags.distinct("id").length

//подсчитайте число фильмов с конкретным тегом - woman
db.tags.distinct("id", {"name" : "woman"}).length
db.tags.find({"name" : "woman"}).count()

//используя группировку данных ($groupby) вывести top-3 самых распространённых тегов
db.tags.aggregate([
{
    $group :  {_id : "$name", count:  {$sum : 1} }
} ,{
    $sort : {count : -1 }
}, {
    $limit : 3
} 
])

db.tags.aggregate([
{
    $group :  {_id : "$name", id : {$addToSet: "$id"} }
} ,
{
    $unwind:"$id"
},
{
    $group : {_id: "$_id", id_count: {$sum : 1}}
},
{
    $sort : {id_count : -1 }
}, 
{
    $limit : 3}

 ])

