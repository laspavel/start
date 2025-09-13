defaults domains | tr , '\n' | while read domain; do
    echo "# $domain"
    defaults read "$domain"
done > current_defaults2.txt