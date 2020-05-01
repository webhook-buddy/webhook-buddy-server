-- password: 1Password
INSERT INTO public.users(
	created_at, updated_at, first_name, last_name, email, password_hash, password_salt, last_ip_address, last_logged_in_at, last_activity_at)
	VALUES (
        current_timestamp,
        current_timestamp,
        'Lou',
        'Ferigno',
        'lou@email.com',
        '5769a4654127111a1f636ed3707a209f3e7bad8864d106e65dd6f9600c131f9c34606f5e0d5434ee65e65fdc651d6084e385e1e5abe6e440e316d74ede7e86cc9baf53edced1621a21a80da491a2239a732e22ec8f0392c95ff123c1a6b4eb70b7aa07cb787d942cebd5b1b63ff315d6be2519bff5e479410e16656f513b1a955266eea44b2566f875133146c3050337161e489cc92700a99b4e77bc67fe8bead4a16aa67840836218267080d25a3b7456a77c1dbc2cb1a098d992b09ab350838ba69280234a68d635bb7f9a28dbd8747cf00d1cc59bf176342f58a09d547dfe85dd93a9e152017489c1ac35fe5cf36fc46d85a64d594ca023623da473ff0c9ffc8e9bc3b7330a59d36d85ceaaefc5d892511eebc846fa2beb42fa57544b5acd292ce8db93a25faeca0ec58e35a61432f4eb56e1f5b66ab6dbe8aa320169e5ea7a414c94e24bfab8a79ffaea92a7fcdc4d695410844ae6761a3bd291fd62dd6ecf63dedbe1b794a482de708f4c7073a957acfb3c1119a4457557d04b1e5b5ea8e5f1be054ce312a0863302a0d343fe022bc2d0d2ea69932d3e8d125e1d5081aeddb9a47787276f6712f97b6a820daba7551882c050a757ac3962959cb99ca8e39bdb8331a756fc2bcac332d5708a25491fdbc2a35c4f3d09d3c0870142300e2d42cdcd32fd6a2124b241183ad82e211f5043931cff3e095eb40b9dde32cbf439',
        '3903c56aff9ba0974f07b776a27bd0b1',
        '123.123.123.123',
        current_timestamp,
        current_timestamp);
	
INSERT INTO public.endpoints(
	created_at, reference_id, name)
	VALUES (current_timestamp, 'caa0699e-3fab-482c-8c4b-6424d898439f', 'ACME w/ Stripe');
	
INSERT INTO public.user_endpoints(
	user_id, endpoint_id, created_at)
	VALUES (1, 1, current_timestamp);