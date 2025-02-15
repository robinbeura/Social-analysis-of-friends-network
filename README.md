Friends TV Show Network Analysis

📌 Project Overview

This project analyzes the character interaction network from the TV series Friends. Using graph theory and network analysis techniques, we explore relationships, community structures, and key characters within the show.

📂 Dataset

The dataset consists of an edgelist containing character interactions:

from – The source character of an interaction

to – The target character of an interaction

weight – The strength of the interaction (e.g., frequency of dialogues exchanged)

🔧 Preprocessing Steps

Load and clean data: Extract relevant columns from the edgelist.

Filter out main characters' internal connections: This helps identify broader relationships outside the core six.

Create an undirected graph: Convert the edgelist into an igraph object for analysis.

📊 Network Analysis

1️⃣ Basic Network Statistics

Number of Nodes (Characters): vcount(friends_graph)

Number of Edges (Interactions): ecount(friends_graph)

Is the Graph Simple? (No loops/multi-edges): is.simple(friends_graph)

Is the Graph Connected? (Weakly or strongly connected): is.connected(friends_graph)

Component Analysis: Identify maximal connected components.

Reciprocity: Measures mutual interactions between characters.

Transitivity (Clustering Coefficient): Indicates the probability of two connected characters also being connected to a third.

Average Path Length & Diameter: Measures how distant characters are from each other.

2️⃣ Graph Visualizations

Fruchterman-Reingold Layout: Optimized for evenly spaced node placement.

Kamada-Kawai Layout: Helps reveal network clusters.

Louvain Community Detection: Identifies distinct communities in the show.

Clique Analysis: Finds groups of tightly connected characters.

3️⃣ Centrality Measures

Betweenness Centrality: Determines characters that frequently bridge other characters.

Degree Centrality: Identifies the most socially active characters.

Closeness Centrality: Measures how efficiently a character can reach others.

📌 Key Findings

🔹 Chandler has the highest betweenness centrality, making him a central character in the network.

🔹 Joey and Ross are highly connected, meaning they interact with many characters frequently.

🔹 The network is well-clustered, showing natural communities formed over the seasons.

🔹 Louvaine community detection reveals 6 strong communities, each representing subgroups of characters interacting more frequently with each other.

📈 Community Analysis

We extracted the top 5 most important characters within each detected community based on degree centrality. Additionally, we analyzed the smallest communities, helping us understand isolated character interactions.

🎨 Graph Visualization Examples



Different layouts were used to highlight character relationships and communities.

🛠 Technologies Used

R (tidyverse, igraph) for network analysis and visualization.

knitr & kable for generating summary tables.

📌 Next Steps

✅ Improve visualization aesthetics by using interactive plotting libraries.
✅ Analyze temporal changes in character interactions across seasons.
✅ Explore sentiment analysis on dialogues to categorize relationships.

📢 Contributions & Feedback

If you have suggestions, feel free to contribute or provide feedback! 🚀

🎬 "Could I BE any more central to this network?" - Chandler Bing 😆
