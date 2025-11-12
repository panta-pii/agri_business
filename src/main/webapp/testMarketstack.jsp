<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Test Marketstack Agri Prices</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .change-up   { color: #28a745; }
        .change-down { color: #dc3545; }
        .badge-up    { background:#d4edda; color:#155724; }
        .badge-down  { background:#f8d7da; color:#721c24; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4">Test Marketstack Agri Prices</h1>

    <button onclick="testServlet()" class="btn btn-primary mb-3">Test Servlet</button>

    <div id="result"></div>
</div>

<script>
function testServlet() {
    fetch('market-data')
        .then(r => r.json())
        .then(data => {
            const resultDiv = document.getElementById('result');

            // ---- 1. Live-data banner ----
            if (data.source === 'marketstack') {
                resultDiv.innerHTML = `
                    <div class="alert alert-success d-flex align-items-center">
                        <i class="fas fa-check-circle me-2"></i> Live Data Loaded!
                    </div>`;
            } else {
                resultDiv.innerHTML = `
                    <div class="alert alert-warning">
                        Warning: Using fallback data (API error or empty response)
                    </div>`;
            }

            // ---- 2. Table header ----
            let html = `
                <h4 class="mt-3">Latest Prices:</h4>
                <div class="table-responsive">
                    <table class="table table-striped table-hover align-middle">
                        <thead class="table-success">
                            <tr>
                                <th>Symbol</th>
                                <th>Close ($)</th>
                                <th>Change</th>
                                <th>Category</th>
                            </tr>
                        </thead>
                        <tbody>`;

            // ---- 3. Rows ----
            data.data.market.forEach(item => {
                const change = ((item.close - item.open) / item.open * 100).toFixed(2);
                const changeClass = change >= 0 ? 'change-up' : 'change-down';
                const badgeClass  = change >= 0 ? 'badge-up' : 'badge-down';
                const sign = change >= 0 ? '+' : '';

                html += `
                    <tr>
                        <td><strong>${item.symbol}</strong></td>
                        <td class="text-end">$${item.close.toFixed(2)}</td>
                        <td class="${changeClass} text-end">
                            <span class="badge ${badgeClass}">${sign}${change}%</span>
                        </td>
                        <td>${item.category}</td>
                    </tr>`;
            });

            html += `</tbody></table></div>`;
            resultDiv.innerHTML += html;
        })
        .catch(err => {
            document.getElementById('result').innerHTML =
                `<div class="alert alert-danger">Error: ${err.message}</div>`;
        });
}
</script>
</body>
</html>