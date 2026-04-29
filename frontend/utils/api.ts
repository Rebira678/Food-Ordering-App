const BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000';

export const api = {
    post: async (endpoint: string, body: any) => {
        const res = await fetch(`${BASE_URL}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });
        if (!res.ok) throw new Error('API POST Request Failed');
        const data = await res.json();
        return { data };
    },
    get: async (endpoint: string) => {
        const res = await fetch(`${BASE_URL}${endpoint}`);
        if (!res.ok) throw new Error('API GET Request Failed');
        const data = await res.json();
        return { data };
    }
};
