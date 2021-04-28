
library(tidyverse)
library(readr)
library(igraph)

##### ABOUT THE DATASET
### Add comments for each analysis to make it easier for us to discuss that on report and ppt


# read friends full series edgelist 
edgelistRead <- readRDS("friends_full_series_edgelist.RDS") 
edgelist <- subset(edgelistRead, select =c("from", "to", "weight"))
knitr::kable(edgelist %>% head(10))

##The main character in the network would form strong communities and 
##we want to thus remove the edges between the characters to show they don't know each other
friends <- c("Phoebe", "Monica", "Rachel", "Joey", "Ross", "Chandler") 
edgelist_without <- edgelist %>% 
  dplyr::filter(!(from %in% friends & to %in% friends))

edgelist_matrix <- as.matrix(edgelist_without[ ,c("from", "to")]) 
  friends_graph <- igraph::graph_from_edgelist(edgelist_matrix, directed = F) %>% 
  igraph::set.edge.attribute("weight", value = edgelist_without$weight)

V(friends_graph)$label <- V(friends_graph)$name

##########           Basic network statistics

## Plotting using two layouts
l1 <- layout.fruchterman.reingold(friends_graph)
plot(friends_graph, layout=l1, 
     edge.arrow.size=0.2, 
     vertex.label = NA,
     vertex.label.cex=0.75, 
     vertex.label.family="Helvetica",
     vertex.label.font=2,
     vertex.shape="circle",
     vertex.size=5, 
     vertex.label.color="black", 
     edge.width=0.5, main = "Fruchterman Reingold layout")

l2 = layout.kamada.kawai(friends_graph)
igraph.options(vertex.size=3, edge.arrow.size=0.5,vertex.label=NULL)
plot(friends_graph,edge.arrow.size=0.2, 
     vertex.label.cex=0.75, 
     vertex.label.family="Helvetica",
     vertex.label.font=2,
     vertex.shape="circle",
     vertex.label = NA,
     vertex.size=5, 
     vertex.label.color="black",
     edge.width=0.5, layout =l2, main = "kamada kawai layout")

E(friends_graph)
V(friends_graph)
ecount(friends_graph)   # Edges for each node
vcount(friends_graph)   # nodes count

is.simple(friends_graph)  # True

is.connected(friends_graph)  #decides whether the graph is weakly or strongly connected.

components(friends_graph)  # Calculate the maximal (weakly or strongly) connected components of a graph

stgclusters <- clusters(friends_graph, mode="strong")$membership    #if strong cluster
plot(friends_graph, vertex.color = stgclusters, vertex.size=3, vertex.label= NA)

weakclusters <- clusters(friends_graph, mode="weak")$membership   
plot(friends_graph, vertex.color = weakclusters, vertex.size=3, vertex.label= NA)  

reciprocity(friends_graph)  # measures the propensity of each edge to be a mutual edge

transitivity(friends_graph, type = "globalundirected") # also known as clustering coefficient, measures that probability that adjacent nodes of a network are connected
transitivity(friends_graph, type = "localundirected")

mean_distance(friends_graph, directed=F)  ## average number of edges between any two nodes


diameter(friends_graph, directed=F, weights=NA) #length of the longest path (in number of edges) between two nodes
get_diameter(friends_graph, directed=TRUE, weights=NA)  ###Shows the diameter


### Cliques 
maximal.cliques(friends_graph)
clique.number(friends_graph)  ## Size of the largest clique = 10
table(sapply(maximal.cliques(friends_graph), length))  ###Table shows the maximal cliques and their length

clique <- maximal.cliques(friends_graph)
cliques_large <- largest.cliques(friends_graph)
cliques_6 <- c(cliques_large[[5]]) ## There are 6 maximal cliques of length 10. Showing here just 1 out of the 6.
g2 <- induced.subgraph(graph=friends_graph,vids=(cliques_6))
plot(g2,main="cliques of size 6",vertex.label.cex=0.75, 
     vertex.label.family="Helvetica",
     vertex.label.font=2,
     vertex.shape="circle",
     vertex.label = V(g2)$label,
     vertex.size=5, 
     vertex.label.color="black",
     edge.width=0.2)

head(sort(betweenness(friends_graph), decreasing = T), n = 10) ###Found betweenness centrality and sorted based on the maximum paths they appear in
plot(friends_graph, layout=l1,
     edge.arrow.size=0.5, 
     vertex.label.cex=0.7, 
     vertex.label.family="Helvetica",
     vertex.label.font=2,
     vertex.shape="circle",
     vertex.label = ifelse(betweenness(friends_graph)>6000, V(friends_graph)$label, NA),
     vertex.size=betweenness(friends_graph)/5000,
     vertex.label.color="black", 
     edge.width=0.5)

avg_degree = ecount(friends_graph)/vcount(friends_graph)   # avg_degree of the network [1] 4.555385

head(sort(degree(friends_graph), decreasing = T), n = 10)   ###Maximum information flows from chandler. Ofcourse he can't keep a secret

head(sort(closeness(friends_graph), decreasing = T), n = 10) ## how many steps is required to access every other vertex from a given vertex
closeness(friends_graph)


########## Using the Louvain algorithm to find communities #############

# run louvain with edge weights 
louvain_partition <- igraph::cluster_louvain(friends_graph, weights = E(friends_graph)$weight) 
# assign communities to graph 
friends_graph$community <- louvain_partition$membership 
# see how many communities there are 
unique(friends_graph$community) 

######### Understanding the communities a little more ###########

communities <- data.frame()
for (i in unique(friends_graph$community)) { 
  # create subgraphs for each community 
  subgraph <- induced_subgraph(friends_graph, v = which(friends_graph$community == i)) 
  # get size of each subgraph 
  size <- igraph::gorder(subgraph) 
  # get betweenness centrality 
  btwn <- igraph::betweenness(subgraph) 
  
  communities <- communities %>% 
    dplyr::bind_rows(data.frame(
     community = i, 
     n_characters = size, 
     most_important = names(which(btwn == max(btwn))) 
   ) 
   ) 
} 
knitr::kable(
  communities %>% 
    dplyr::select(community, n_characters, most_important)
)

######## Getting the top 5 most important characters in each of the 6 communities ###########

top_five <- data.frame() 
for (i in unique(friends_graph$community)) { 
  # create subgraphs for each community 
  subgraph <- induced_subgraph(friends_graph, v = which(friends_graph$community == i)) 
  # for larger communities 
  if (igraph::gorder(subgraph) > 20) { 
    # get degree 
    degree <- igraph::degree(subgraph) 
    # get top five degrees 
    top <- names(head(sort(degree, decreasing = TRUE), 5)) 
    result <- data.frame(community = i, rank = 1:5, character = top) 
  } else { 
    result <- data.frame(community = NULL, rank = NULL, character = NULL) 
  } 
  top_five <- top_five %>% 
    dplyr::bind_rows(result) 
} 
knitr::kable(
  top_five %>% 
    tidyr::pivot_wider(names_from = rank, values_from = character) 
)


########### Visualizing these communities ###########

# give our nodes some properties, incl scaling them by degree and coloring them by community 
#V(friends_graph)$size <- 3
V(friends_graph)$frame.color <- "white" 
V(friends_graph)$color <- friends_graph$community
V(friends_graph)$label <- V(friends_graph)$name 
V(friends_graph)$label.cex <- 1.5 
# also color edges according to their starting node 
edge.start <- ends(friends_graph, es = E(friends_graph), names = F)[,1] 
E(friends_graph)$color <- V(friends_graph)$color[edge.start] 
E(friends_graph)$arrow.mode <- 0 # only label central characters 
v_labels <- which(V(friends_graph)$name %in% friends) 
for (i in 1:length(V(friends_graph))) { 
  if (!(i %in% v_labels)) { V(friends_graph)$label[i] <- "" } 
}

l1 <- layout_on_sphere(friends_graph)
plot(friends_graph, rescale = T, layout = l1, main = "'Friends' Network - All Seasons",vertex.size =3)


l2 <- layout_with_mds(friends_graph) 
plot(friends_graph, rescale = T, layout = l2, main = "'Friends' Network - All Seasons",vertex.size = 3)

############### The smallest communities ###########

small_communities <- data.frame() 
for (i in unique(friends_graph$community)) { 
  # create subgraphs for each community 
  subgraph <- induced_subgraph(friends_graph, v =   which(friends_graph$community == i)) 
  # for larger communities 
  if (igraph::gorder(subgraph) < 20) { 
    # get degree 
    degree <- igraph::degree(subgraph) 
    # get top ten degrees 
    top <- names(sort(degree, decreasing = TRUE)) 
    result <- data.frame(community = i, rank = 1:length(top), character = top) 
  } else { 
    result <- data.frame(community = NULL, rank = NULL, character = NULL) 
  } 
  small_communities <- small_communities %>%  
    dplyr::bind_rows(result) 
} 
knitr::kable( 
  small_communities %>% 
    tidyr::pivot_wider(names_from = rank, values_from = character) 
)
