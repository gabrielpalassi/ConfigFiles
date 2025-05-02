// Bookmarklet (URL) or console script for Instagram follower analysis
// Requirements: Logged into Instagram and on the Instagram website
// Outputs:
// 1. List of users that follow you
// 2. List of users you follow
// 3. Users that don't follow you back
// 4. Users you don't follow back

javascript: (async () => {
  async function fetchUserData(userId, edgeType, data) {
    const hash =
      edgeType === "edge_followed_by"
        ? "c76146de99bb02f6415203be841dd25a"
        : "d04b0a864b4b54837c0d870b0e77e076";
    let after = "initial";
    while (after) {
      const response = await (
        await fetch(
          `https://www.instagram.com/graphql/query/?query_hash=${hash}&variables=` +
            encodeURIComponent(
              JSON.stringify({
                id: userId,
                include_reel: true,
                fetch_mutual: true,
                first: 50,
                after: after === "initial" ? null : after,
              })
            )
        )
      ).json();
      after = response.data.user[edgeType].page_info.end_cursor;
      data.push(
        ...response.data.user[edgeType].edges.map(({ node }) => ({
          username: node.username,
          full_name: node.full_name,
        }))
      );
    }
  }

  async function runAnalysis() {
    const username = prompt("Enter Instagram username:");
    if (!username) {
      console.error("Username is required!");
      return;
    }
    console.log("The process has started, give it a couple seconds...");
    let followers = [];
    let followings = [];
    try {
      let userQuery = await (
        await fetch(
          `https://www.instagram.com/web/search/topsearch/?query=${username}`
        )
      ).json();
      const userId = userQuery.users
        .map((user) => user.user)
        .filter((user) => user.username === username)[0].pk;
      await Promise.all([
        fetchUserData(userId, "edge_followed_by", followers),
        fetchUserData(userId, "edge_follow", followings),
      ]);
      console.log("Users that follow you:", followers);
      console.log("Users that you follow:", followings);
      console.log(
        "Users that don't follow you back:",
        followings.filter(
          (following) =>
            !followers.find(
              (follower) => follower.username === following.username
            )
        )
      );
      console.log(
        "Users that you don't follow back:",
        followers.filter(
          (follower) =>
            !followings.find(
              (following) => following.username === follower.username
            )
        )
      );
    } catch (error) {
      console.error("Error:", error);
    }
  }

  runAnalysis();
})();
